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


def vscode_is_running():
    if os.name == "nt":
        tasklist = shutil.which("tasklist")
        if not tasklist:
            raise RuntimeError("cannot check whether VS Code is running (tasklist unavailable)")
        result = subprocess.run(
            [tasklist, "/FI", "IMAGENAME eq Code.exe", "/NH"],
            check=True,
            capture_output=True,
            text=True,
        )
        return "code.exe" in result.stdout.lower()

    pgrep = shutil.which("pgrep")
    if pgrep:
        for process_name in ("Code", "code", "code-insiders", "code-oss"):
            if subprocess.run([pgrep, "-x", process_name], stdout=subprocess.DEVNULL).returncode == 0:
                return True
        return False

    ps = shutil.which("ps")
    if not ps:
        raise RuntimeError("cannot check whether VS Code is running (pgrep and ps unavailable)")
    result = subprocess.run([ps, "-A", "-o", "comm="], check=True, capture_output=True, text=True)
    process_names = {Path(line.strip()).name.lower() for line in result.stdout.splitlines()}
    return bool(process_names & {"code", "code-insiders", "code-oss"})


def storage_path():
    override = os.environ.get("CHEZMOI_VSCODE_PROFILE_STORAGE_PATH")
    if override:
        return Path(override).expanduser()
    if os.name == "nt":
        appdata = os.environ.get("APPDATA")
        if not appdata:
            raise RuntimeError("APPDATA is not set; cannot locate VS Code profile storage")
        return Path(appdata) / "Code" / "User" / "globalStorage" / "storage.json"
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support" / "Code" / "User" / "globalStorage" / "storage.json"
    config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    return config_home / "Code" / "User" / "globalStorage" / "storage.json"


def install_copilot_extensions(profile_names):
    code = os.environ.get("CHEZMOI_VSCODE_CLI") or shutil.which("code")
    if not code:
        raise RuntimeError("the VS Code 'code' command is required to install Copilot extensions")

    version_result = subprocess.run([code, "--version"], check=True, capture_output=True, text=True)
    version_match = re.match(r"\s*(\d+)\.(\d+)\.(\d+)", version_result.stdout)
    if not version_match:
        raise RuntimeError("cannot determine the installed VS Code version from 'code --version'")
    version = tuple(int(component) for component in version_match.groups())
    if version >= (1, 116, 0):
        print("GitHub Copilot is built into this VS Code version; skipping Marketplace installation.")
        return

    extensions = ("GitHub.copilot", "GitHub.copilot-chat")
    for profile_name in profile_names:
        for extension in extensions:
            command = [code, "--install-extension", extension]
            if profile_name != "Default":
                command.extend(("--profile", profile_name))
            subprocess.run(command, check=True)


def configure_profiles(wanted_profiles):
    if not isinstance(wanted_profiles, list) or any(not isinstance(item, dict) for item in wanted_profiles):
        raise RuntimeError("configured VS Code profiles must be a JSON list of objects")
    if os.environ.get("CHEZMOI_PROFILE_SETUP_TESTING") != "1" and not os.environ.get(
        "CHEZMOI_VSCODE_PROFILE_STORAGE_PATH"
    ):
        if vscode_is_running():
            raise RuntimeError("quit VS Code before running chezmoi apply to update profile contents")

    path = storage_path()
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
    profile_names = ["Default"]
    for wanted in wanted_profiles:
        name = wanted["name"]
        if name not in profile_names:
            profile_names.append(name)
        if name == "Default":
            continue
        matches = [profile for profile in profiles if profile.get("name") == name]
        if len(matches) > 1:
            raise RuntimeError("multiple VS Code profiles have the same configured name")
        if matches:
            profile = matches[0]
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
        for resource in ("settings", "keybindings", "tasks", "mcp", "snippets"):
            if flags.get(resource) is not True:
                flags[resource] = True
                changed = True
        # Keep at least extensions profile-specific; VS Code requires one
        # configuration category to remain in the profile itself.
        if flags.get("extensions") is not False:
            flags["extensions"] = False
            changed = True

    if changed:
        path.parent.mkdir(parents=True, exist_ok=True)
        mode = path.stat().st_mode & 0o777 if path.exists() else 0o600
        fd, temporary_name = tempfile.mkstemp(prefix="storage.json.", dir=path.parent)
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as output:
                json.dump(data, output, ensure_ascii=False, indent=2)
                output.write("\n")
            os.chmod(temporary_name, mode)
            os.replace(temporary_name, path)
        finally:
            if os.path.exists(temporary_name):
                os.unlink(temporary_name)
        print("Configured VS Code profile contents to inherit shared settings, shortcuts, tasks, MCP servers, and snippets.")

    install_copilot_extensions(profile_names)


def main():
    try:
        configure_profiles(json.load(sys.stdin))
    except (OSError, ValueError, KeyError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"Unable to configure VS Code profile contents: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
