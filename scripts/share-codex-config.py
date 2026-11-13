#!/usr/bin/env python3

"""Merge existing profile Codex settings and link profiles to one config."""

import copy
import datetime
import json
import math
import os
import re
import stat
import sys
import tempfile
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    try:
        import tomli as tomllib
    except ModuleNotFoundError:
        print("Sharing Codex config requires Python 3.11+ or the tomli package.", file=sys.stderr)
        raise SystemExit(1)


def merge_tables(target, source):
    """Merge TOML mappings, refusing to choose between different values."""
    for key, value in source.items():
        if key not in target:
            target[key] = copy.deepcopy(value)
        elif isinstance(target[key], dict) and isinstance(value, dict):
            merge_tables(target[key], value)
        elif target[key] != value:
            raise ValueError("profile Codex configs have conflicting settings")


def quote_key(key):
    """Return a valid TOML key, quoting keys that need it."""
    if re.fullmatch(r"[A-Za-z0-9_-]+", key):
        return key
    return json.dumps(key, ensure_ascii=True)


def format_value(value):
    """Serialize a TOML scalar, array, or inline table."""
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=True)
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        if math.isnan(value):
            return "nan"
        if math.isinf(value):
            return "inf" if value > 0 else "-inf"
        return repr(value)
    if isinstance(value, datetime.datetime):
        return value.isoformat()
    if isinstance(value, (datetime.date, datetime.time)):
        return value.isoformat()
    if isinstance(value, list):
        return "[" + ", ".join(format_value(item) for item in value) + "]"
    if isinstance(value, dict):
        items = ", ".join(f"{quote_key(key)} = {format_value(item)}" for key, item in value.items())
        return "{ " + items + " }"
    raise ValueError("Codex config contains an unsupported TOML value")


def serialize_table(table, path=()):
    """Serialize a TOML mapping while preserving nested table structure."""
    lines = []
    if path:
        lines.append("[" + ".".join(quote_key(part) for part in path) + "]")

    nested = []
    for key, value in table.items():
        if isinstance(value, dict):
            nested.append((key, value))
        else:
            lines.append(f"{quote_key(key)} = {format_value(value)}")

    for key, value in nested:
        if lines and lines[-1] != "":
            lines.append("")
        lines.extend(serialize_table(value, path + (key,)))
    return lines


def read_config(path):
    """Read one TOML config without displaying its contents."""
    try:
        return tomllib.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, ValueError) as error:
        raise ValueError("a Codex config could not be read or parsed; no files were changed") from error


def resolved_shared_path(path):
    """Resolve the shared config target while preserving an existing symlink."""
    if path.is_symlink():
        try:
            target = path.resolve(strict=True)
        except OSError as error:
            raise ValueError("the shared Codex config symlink is broken; no files were changed") from error
        if not target.is_file():
            raise ValueError("the shared Codex config target is not a file; no files were changed")
        return target
    if path.exists() and not path.is_file():
        raise ValueError("the shared Codex config path is not a file; no files were changed")
    return path


def write_config(path, config):
    """Atomically write a private shared TOML config."""
    path.parent.mkdir(parents=True, exist_ok=True)
    content = "\n".join(serialize_table(config)) + "\n"
    mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o600
    descriptor, temporary_path = tempfile.mkstemp(prefix="config.toml.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as output:
            output.write(content)
        os.chmod(temporary_path, mode)
        os.replace(temporary_path, path)
    finally:
        if os.path.exists(temporary_path):
            os.unlink(temporary_path)


def link_profile_config(path, shared_path):
    """Replace a profile config with an absolute symlink to the shared file."""
    if path.is_symlink():
        try:
            if path.resolve(strict=True) == shared_path.resolve(strict=True):
                return
        except OSError as error:
            raise ValueError("a profile Codex config symlink is broken; no files were changed") from error
    elif path.exists() and not path.is_file():
        raise ValueError("a profile Codex config path is not a file; no files were changed")

    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".codex-config-", dir=path.parent) as temporary_dir:
        temporary_link = Path(temporary_dir) / "config.toml"
        temporary_link.symlink_to(shared_path)
        os.replace(temporary_link, path)


def main():
    """Merge configured profile files and point each profile to the result."""
    try:
        profiles = json.load(sys.stdin)
        if not isinstance(profiles, list) or any(
            not isinstance(profile, str)
            or not re.fullmatch(r"[A-Za-z0-9._-]+", profile)
            or profile in {".", ".."}
            for profile in profiles
        ):
            raise ValueError("configured Codex profile names are invalid; no files were changed")

        profiles_base = Path(os.environ.get("CHEZMOI_PROFILES_DIR", Path.home() / ".config/profiles"))
        shared_path = Path.home() / ".config/codex/config.toml"
        shared_target = resolved_shared_path(shared_path)
        config_files = []
        source_config = os.environ.get("CHEZMOI_CODEX_CONFIG")
        if source_config:
            source_path = Path(source_config)
            if not source_path.is_file():
                raise ValueError("the shared Codex config source is missing; no files were changed")
            config_files.append(source_path.resolve(strict=True))
        if shared_target.exists():
            config_files.append(shared_target)

        profile_paths = [profiles_base / profile / "codex/config.toml" for profile in profiles]
        shared_resolved = shared_target.resolve(strict=False)
        for profile_path in profile_paths:
            profile_home = (profiles_base / profile_path.parts[-3]).resolve(strict=False)
            try:
                shared_resolved.relative_to(profile_home)
            except ValueError:
                pass
            else:
                raise ValueError("the shared Codex config must not be inside a profile home; no files were changed")
            if profile_path.exists() or profile_path.is_symlink():
                try:
                    resolved = profile_path.resolve(strict=True)
                except OSError as error:
                    raise ValueError("a profile Codex config symlink is broken; no files were changed") from error
                if resolved != shared_resolved:
                    config_files.append(resolved)

        unique_files = []
        seen_files = set()
        for path in config_files:
            resolved = path.resolve(strict=True)
            if resolved not in seen_files:
                unique_files.append(resolved)
                seen_files.add(resolved)

        shared_config = {}
        for path in unique_files:
            merge_tables(shared_config, read_config(path))

        auth_store = shared_config.get("cli_auth_credentials_store")
        if auth_store not in (None, "file"):
            raise ValueError(
                'cli_auth_credentials_store must remain "file" to keep authentication per CODEX_HOME; no files were changed'
            )
        shared_config["cli_auth_credentials_store"] = "file"

        current_config = read_config(shared_target) if shared_target.exists() else None
        if current_config != shared_config:
            write_config(shared_target, shared_config)
        elif not shared_path.exists():
            write_config(shared_target, shared_config)

        for profile_path in profile_paths:
            link_profile_config(profile_path, shared_path)
    except (OSError, ValueError, TypeError) as error:
        print(f"Unable to share Codex profile config: {error}", file=sys.stderr)
        return 1

    print(f"Shared Codex config across {len(profiles)} profiles; authentication remains in each CODEX_HOME.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
