#!/usr/bin/env python3

"""Configure VS Code profile resources to inherit selected defaults."""

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

PROFILE_RESOURCES = (
    "settings",
    "keybindings",
    "tasks",
    "mcp",
    "snippets",
    "prompts",
    "languageModels",
)
COPILOT_EXTENSIONS = ("GitHub.copilot", "GitHub.copilot-chat")
VSCODE_DATA_DIRECTORIES = {
    "stable": "Code",
    "insiders": "Code - Insiders",
    "oss": "Code - OSS",
}


def is_wsl():
    """Return whether this process is running inside Windows Subsystem for Linux."""
    # WSL_DISTRO_NAME is reliable in user sessions; the kernel check covers shells without it.
    if os.environ.get("WSL_DISTRO_NAME"):
        return True
    try:
        return "microsoft" in Path("/proc/sys/kernel/osrelease").read_text(encoding="utf-8").lower()
    except OSError:
        return False


def uses_windows_vscode_from_wsl(code):
    """Return whether a WSL process is invoking the Windows VS Code CLI."""
    if not is_wsl():
        return False
    # Windows executables may be exposed directly or through WSL's default /mnt/<drive> mount.
    code_path = str(code).replace("\\", "/").lower()
    return Path(code).suffix.lower() in {".bat", ".cmd", ".exe"} or bool(
        re.match(r"^/mnt/[a-z]/", code_path)
    )


def find_vscode_cli():
    """Find the configured VS Code CLI, preferring the explicit environment override."""
    override = os.environ.get("CHEZMOI_VSCODE_CLI")
    if override:
        return override
    for command in ("code", "code-insiders", "code-oss"):
        code = shutil.which(command)
        if code:
            return code
    return None


def vscode_variant(code):
    """Determine the VS Code distribution from its CLI path or explicit override."""
    override = os.environ.get("CHEZMOI_VSCODE_VARIANT", "").strip().lower()
    if override:
        if override not in {"stable", "insiders", "oss"}:
            raise RuntimeError("CHEZMOI_VSCODE_VARIANT must be stable, insiders, or oss")
        return override
    code_path = str(code).lower()
    if "insider" in code_path:
        return "insiders"
    if "code-oss" in code_path or "code - oss" in code_path:
        return "oss"
    return "stable"


def vscode_data_directory_name(variant):
    """Map a VS Code distribution name to its user-data directory name."""
    return VSCODE_DATA_DIRECTORIES[variant]


def windows_appdata_from_wsl():
    """Resolve Windows APPDATA and convert it to a path accessible from WSL."""
    cmd = shutil.which("cmd.exe") or shutil.which("cmd")
    wslpath = shutil.which("wslpath")
    if not cmd or not wslpath:
        raise RuntimeError("cmd.exe and wslpath are required to locate Windows VS Code storage from WSL")
    # VS Code launched from WSL still stores profiles in the Windows user directory.
    result = subprocess.run([cmd, "/C", "echo %APPDATA%"], check=True, capture_output=True, text=True)
    windows_appdata = result.stdout.strip()
    if not windows_appdata or windows_appdata == "%APPDATA%":
        raise RuntimeError("Windows APPDATA could not be resolved from WSL")
    path_result = subprocess.run([wslpath, "-u", windows_appdata], check=True, capture_output=True, text=True)
    appdata = path_result.stdout.strip()
    if not appdata:
        raise RuntimeError("Windows APPDATA could not be converted to a WSL path")
    return Path(appdata)


def vscode_process_names():
    """Return normalized VS Code process names used by the ps fallback."""
    return {"code", "code-insiders", "code-oss", "code - insiders", "code - oss"}


def windows_vscode_is_running():
    """Check stable, Insiders, and OSS VS Code processes on Windows."""
    tasklist = shutil.which("tasklist.exe" if is_wsl() else "tasklist")
    if not tasklist:
        raise RuntimeError("cannot check whether VS Code is running (tasklist unavailable)")
    for image_name in ("Code.exe", "Code - Insiders.exe", "Code - OSS.exe"):
        result = subprocess.run(
            [tasklist, "/FI", f"IMAGENAME eq {image_name}", "/NH"],
            check=True,
            capture_output=True,
            text=True,
        )
        if image_name.lower() in result.stdout.lower():
            return True
    return False


def vscode_is_running(code):
    """Check for running VS Code processes using the host platform's process tools."""
    if os.name == "nt" or uses_windows_vscode_from_wsl(code):
        return windows_vscode_is_running()

    process_names = vscode_process_names()
    pgrep_names = process_names
    if sys.platform == "darwin":
        macos_process_names = {"Code Helper", "Code Helper (Renderer)", "Code Helper (Plugin)"}
        pgrep_names = process_names | macos_process_names
        process_names |= {name.lower() for name in macos_process_names}
    pgrep = shutil.which("pgrep")
    if pgrep:
        return any(
            subprocess.run([pgrep, "-x", name], stdout=subprocess.DEVNULL).returncode == 0
            for name in pgrep_names
        )

    ps = shutil.which("ps")
    if not ps:
        raise RuntimeError("cannot check whether VS Code is running (pgrep and ps unavailable)")
    result = subprocess.run([ps, "-A", "-o", "comm="], check=True, capture_output=True, text=True)
    running = {Path(line.strip()).name.lower() for line in result.stdout.splitlines()}
    return bool(running & process_names)


def portable_storage_path(code):
    """Return the storage path for a portable install, or None if it is not detected."""
    try:
        code_path = Path(code).resolve()
    except OSError:
        return None
    # Portable VS Code places user data under data/user-data beside its installation.
    for install_root in (code_path.parent, *code_path.parents):
        portable_data = install_root / "data"
        if portable_data.is_dir() and (
            (portable_data / "user-data").is_dir() or (portable_data / "extensions").is_dir()
        ):
            return portable_data / "user-data" / "User" / "globalStorage" / "storage.json"
    return None


def storage_path(code):
    """Locate VS Code's profile storage for the CLI's platform and distribution."""
    # An explicit path supports custom --user-data-dir and nonstandard installations.
    override = os.environ.get("CHEZMOI_VSCODE_PROFILE_STORAGE_PATH")
    if override:
        return Path(override).expanduser()
    portable_path = portable_storage_path(code)
    if portable_path:
        return portable_path
    variant_dir = vscode_data_directory_name(vscode_variant(code))
    if os.name == "nt" or uses_windows_vscode_from_wsl(code):
        appdata = windows_appdata_from_wsl() if is_wsl() else windows_appdata()
        return appdata / variant_dir / "User" / "globalStorage" / "storage.json"
    if sys.platform == "darwin":
        return (
            Path.home()
            / "Library"
            / "Application Support"
            / variant_dir
            / "User"
            / "globalStorage"
            / "storage.json"
        )
    config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    return config_home / variant_dir / "User" / "globalStorage" / "storage.json"


def windows_appdata():
    """Return native Windows APPDATA as a Path."""
    appdata = os.environ.get("APPDATA")
    if not appdata:
        raise RuntimeError("APPDATA is not set; cannot locate VS Code profile storage")
    return Path(appdata)


def install_copilot_extensions(code, profile_names):
    """Install Copilot extensions into requested profiles when the CLI version needs them."""
    version_result = subprocess.run([code, "--version"], check=True, capture_output=True, text=True)
    version_match = re.match(r"\s*(\d+)\.(\d+)\.(\d+)", version_result.stdout)
    if not version_match:
        raise RuntimeError("cannot determine the installed VS Code version from 'code --version'")
    version = tuple(int(component) for component in version_match.groups())
    if version >= (1, 116, 0):
        print("GitHub Copilot is built into this VS Code version; skipping Marketplace installation.")
        return

    for profile_name in profile_names:
        for extension in COPILOT_EXTENSIONS:
            command = [code, "--install-extension", extension]
            if profile_name != "Default":
                command.extend(("--profile", profile_name))
            subprocess.run(command, check=True)


def write_json_atomically(path, data, indent):
    """Write JSON atomically while preserving the target's mode when it exists."""
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = path.stat().st_mode & 0o777 if path.exists() else 0o600
    fd, temporary_name = tempfile.mkstemp(prefix=f"{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as output:
            json.dump(data, output, ensure_ascii=False, indent=indent)
            output.write("\n")
        os.chmod(temporary_name, mode)
        os.replace(temporary_name, path)
    finally:
        if os.path.exists(temporary_name):
            os.unlink(temporary_name)


def profile_settings_path(user_data_dir, profile):
    """Return a profile's settings path, rejecting unsafe or symlinked locations."""
    location = profile.get("location")
    if (
        not isinstance(location, str)
        or not location
        or location in {".", ".."}
        or "/" in location
        or "\\" in location
    ):
        raise RuntimeError("VS Code profile location has an unsupported format")
    profiles_dir = user_data_dir / "profiles"
    profile_dir = profiles_dir / location
    if profiles_dir.is_symlink() or profile_dir.is_symlink():
        raise RuntimeError("refusing to write settings through a symlinked VS Code profile directory")
    return profile_dir / "settings.json"


def configure_profile_settings(user_data_dir, profile, wanted):
    """Set profile settings to the configured instruction locations."""
    settings_path = profile_settings_path(user_data_dir, profile)
    if settings_path.is_symlink():
        raise RuntimeError("refusing to replace a symlinked VS Code profile settings file")

    instruction_locations = wanted.get("instructionLocations")
    if not isinstance(instruction_locations, dict) or any(
        not isinstance(path, str) or not isinstance(enabled, bool)
        for path, enabled in instruction_locations.items()
    ):
        raise RuntimeError("VS Code profile instructionLocations must be a JSON object of boolean values")
    profile_settings = {"chat.instructionsFilesLocations": instruction_locations}
    if settings_path.is_file() and settings_path.read_text(encoding="utf-8") == (
        json.dumps(profile_settings, ensure_ascii=False, indent=4) + "\n"
    ):
        return False

    write_json_atomically(settings_path, profile_settings, indent=4)
    return True


def configure_profiles(wanted_profiles):
    """Update profile inheritance in VS Code storage and ensure Copilot is available."""
    if not isinstance(wanted_profiles, list) or any(not isinstance(item, dict) for item in wanted_profiles):
        raise RuntimeError("configured VS Code profiles must be a JSON list of objects")
    code = find_vscode_cli()
    if not code:
        raise RuntimeError("the VS Code 'code' command is required to configure profiles")
    if os.environ.get("CHEZMOI_PROFILE_SETUP_TESTING") != "1" and vscode_is_running(code):
        raise RuntimeError("quit VS Code before running chezmoi apply to update profile contents")

    path = storage_path(code)
    if path.is_symlink():
        raise RuntimeError("refusing to replace a symlinked VS Code storage file")
    data = {}
    if path.exists():
        data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise RuntimeError("VS Code storage must contain a JSON object")

    profiles = data.setdefault("userDataProfiles", [])
    if not isinstance(profiles, list) or any(not isinstance(item, dict) for item in profiles):
        raise RuntimeError("VS Code userDataProfiles storage has an unsupported format")

    changed = False
    settings_changed = False
    profile_names = ["Default"]
    user_data_dir = path.parent.parent
    for wanted in wanted_profiles:
        name = wanted["name"]
        if name not in profile_names:
            profile_names.append(name)
        if name == "Default":
            continue
        changed |= configure_profile(profiles, wanted)
        profile = next(profile for profile in profiles if profile.get("name") == name)
        settings_changed |= configure_profile_settings(user_data_dir, profile, wanted)

    if changed:
        write_json_atomically(path, data, indent=2)
        print(
            "Configured VS Code profiles to keep settings profile-specific and inherit keyboard shortcuts, "
            "tasks, MCP servers, snippets, prompts, and language models."
        )

    if settings_changed:
        print("Configured profile-specific VS Code settings and instruction locations.")

    install_copilot_extensions(code, profile_names)


def configure_profile(profiles, wanted):
    """Set profile resource-source flags; return whether storage changed."""
    name = wanted["name"]
    matches = [profile for profile in profiles if profile.get("name") == name]
    if len(matches) > 1:
        raise RuntimeError("multiple VS Code profiles have the same configured name")
    if matches:
        profile = matches[0]
        changed = False
    else:
        used_locations = {
            str(profile.get("location", "")).rstrip("/").split("/")[-1] for profile in profiles
        }
        safe_id = re.sub(r"[^A-Za-z0-9._-]", "-", wanted["id"]).strip(".-") or "profile"
        location = f"chezmoi-{safe_id}"
        if location in used_locations:
            suffix = hashlib.sha256(name.encode("utf-8")).hexdigest()[:8]
            location = f"{location}-{suffix}"
        profile = {"name": name, "location": location}
        profiles.append(profile)
        changed = True

    flags = profile.setdefault("useDefaultFlags", {})
    if not isinstance(flags, dict):
        raise RuntimeError("VS Code profile useDefaultFlags has an unsupported format")
    for resource in PROFILE_RESOURCES:
        use_default = resource != "settings"
        if flags.get(resource) is not use_default:
            flags[resource] = use_default
            changed = True
    # Keep extensions profile-specific; VS Code requires one category to remain local.
    if flags.get("extensions") is not False:
        flags["extensions"] = False
        changed = True
    return changed


def main():
    """Run setup from JSON on stdin and report configuration errors to stderr."""
    try:
        configure_profiles(json.load(sys.stdin))
    except (OSError, ValueError, KeyError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"Unable to configure VS Code profile contents: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
