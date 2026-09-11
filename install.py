#!/usr/bin/env python3
"""
install.py

Modular installer CLI for macOS Migration Agents, Skills, and Plugins.
Allows selective or bulk installation into project workspaces (.agents) or global configurations (~/.gemini/config).
"""

import sys
import os
import shutil
import argparse
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent

AGENTS = {
    "mac-to-flutter": REPO_ROOT / "agents" / "mac-to-flutter.md",
    "mac-to-electron": REPO_ROOT / "agents" / "mac-to-electron.md",
    "mac-to-maui": REPO_ROOT / "agents" / "mac-to-maui.md",
    "mac-migration-orchestrator": REPO_ROOT / "agents" / "mac-migration-orchestrator.md"
}

SKILLS = {
    "swift-to-flutter": REPO_ROOT / "skills" / "swift-to-flutter",
    "swift-to-electron": REPO_ROOT / "skills" / "swift-to-electron",
    "swift-to-dotnet-maui": REPO_ROOT / "skills" / "swift-to-dotnet-maui"
}

PLUGINS = {
    "mac-to-flutter": REPO_ROOT / "plugins" / "mac-to-flutter",
    "mac-to-electron": REPO_ROOT / "plugins" / "mac-to-electron",
    "mac-to-maui": REPO_ROOT / "plugins" / "mac-to-maui"
}

def resolve_target_base(scope: str, custom_target: str = None) -> Path:
    if custom_target:
        return Path(custom_target).resolve()
    if scope == "global":
        return Path.home() / ".gemini" / "config"
    else:
        return Path.cwd() / ".agents"

def install_item(source: Path, destination: Path, use_symlink: bool = False):
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists() or destination.is_symlink():
        if destination.is_dir() and not destination.is_symlink():
            shutil.rmtree(destination)
        else:
            destination.unlink()

    if use_symlink:
        destination.symlink_to(source.resolve(), target_is_directory=source.is_dir())
        print(f"  [LINK] {source.name} -> {destination}")
    else:
        if source.is_dir():
            shutil.copytree(source, destination)
        else:
            shutil.copy2(source, destination)
        print(f"  [COPY] {source.name} -> {destination}")

def list_available():
    print("\nAvailable Migration Components:")
    print("--------------------------------------------------")
    print("Agents (Standalone Personas):")
    for a in AGENTS:
        print(f"  - {a}")
    print("\nSkills (Executable Runbooks & Toolchains):")
    for s in SKILLS:
        print(f"  - {s}")
    print("\nPlugins (Packaged Agent + Skill Bundles):")
    for p in PLUGINS:
        print(f"  - {p}")
    print("--------------------------------------------------\n")

def main():
    parser = argparse.ArgumentParser(
        description="Install macOS Migration Agents, Skills, and Plugins into Antigravity workspaces or global config."
    )
    parser.add_argument("--list", action="store_true", help="List all available agents, skills, and plugins")
    parser.add_argument("--agent", choices=list(AGENTS.keys()), help="Install a specific agent persona")
    parser.add_argument("--skill", choices=list(SKILLS.keys()), help="Install a specific skill bundle")
    parser.add_argument("--plugin", choices=list(PLUGINS.keys()), help="Install a complete plugin package")
    parser.add_argument("--all", action="store_true", help="Install all agents, skills, and plugins")
    parser.add_argument("--scope", choices=["workspace", "global"], default="workspace", help="Install scope (default: workspace)")
    parser.add_argument("--target-dir", help="Custom destination directory root")
    parser.add_argument("--link", action="store_true", help="Symlink components instead of copying")

    args = parser.parse_args()

    if args.list:
        list_available()
        return

    if not (args.agent or args.skill or args.plugin or args.all):
        parser.print_help()
        sys.exit(1)

    target_base = resolve_target_base(args.scope, args.target_dir)
    print(f"\nInstalling components to: {target_base} (Scope: {args.scope}, Symlink: {args.link})\n")

    if args.agent:
        src = AGENTS[args.agent]
        dest = target_base / "agents" / src.name
        install_item(src, dest, args.link)

    if args.skill:
        src = SKILLS[args.skill]
        dest = target_base / "skills" / src.name
        install_item(src, dest, args.link)

    if args.plugin:
        src = PLUGINS[args.plugin]
        dest = target_base / "plugins" / src.name
        install_item(src, dest, args.link)

    if args.all:
        print("Installing all agents...")
        for name, src in AGENTS.items():
            dest = target_base / "agents" / src.name
            install_item(src, dest, args.link)

        print("\nInstalling all skills...")
        for name, src in SKILLS.items():
            dest = target_base / "skills" / src.name
            install_item(src, dest, args.link)

        print("\nInstalling all plugins...")
        for name, src in PLUGINS.items():
            dest = target_base / "plugins" / src.name
            install_item(src, dest, args.link)

    print("\n✓ Installation completed successfully.\n")

if __name__ == "__main__":
    main()
