#!/usr/bin/env python3
import argparse
import json
import re
import sys
from pathlib import Path


def clean_cell(value: str) -> str:
    value = value.strip()
    value = value.replace("`", "")
    value = value.replace("**", "")
    return value.strip()


def is_placeholder(value: str) -> bool:
    if not value:
        return True
    return "{{" in value or "}}" in value


def extract_table_lines(lines):
    start = None
    for i, line in enumerate(lines):
        if line.strip().startswith("###") and "対象プロジェクト" in line:
            start = i
            break
    if start is None:
        return []

    header_idx = None
    for i in range(start + 1, len(lines)):
        if "|" in lines[i] and "プロジェクト" in lines[i]:
            header_idx = i
            break
    if header_idx is None:
        return []

    table_lines = []
    for i in range(header_idx, len(lines)):
        line = lines[i].strip()
        if not line or "|" not in line:
            break
        table_lines.append(line)
    return table_lines


def parse_table(table_lines):
    rows = []
    for line in table_lines:
        if re.search(r"\|\s*-{2,}\s*\|", line):
            continue
        if "プロジェクト" in line and "パス" in line:
            continue
        parts = [clean_cell(p) for p in line.strip().strip("|").split("|")]
        if len(parts) < 4:
            continue
        project, path, framework, role = parts[:4]
        if any(is_placeholder(v) for v in (project, path, framework, role)):
            continue
        rows.append(
            {
                "project": project,
                "path": path,
                "framework": framework,
                "role": role,
            }
        )
    return rows


def main():
    parser = argparse.ArgumentParser(
        description="Extract project rows from .agents/TEAM.md"
    )
    parser.add_argument(
        "--path", default=".agents/TEAM.md", help="Path to TEAM.md"
    )
    parser.add_argument("--pretty", action="store_true", help="Pretty JSON output")
    parser.add_argument(
        "--fail-on-empty",
        action="store_true",
        help="Exit 2 if no valid project rows found",
    )
    args = parser.parse_args()

    team_path = Path(args.path)
    if not team_path.exists():
        print(f"TEAM.md not found: {team_path}", file=sys.stderr)
        sys.exit(1)

    lines = team_path.read_text(encoding="utf-8").splitlines()
    table_lines = extract_table_lines(lines)
    rows = parse_table(table_lines)

    if args.fail_on_empty and not rows:
        print("No valid project rows found.", file=sys.stderr)
        sys.exit(2)

    indent = 2 if args.pretty else None
    print(json.dumps(rows, ensure_ascii=False, indent=indent))


if __name__ == "__main__":
    main()
