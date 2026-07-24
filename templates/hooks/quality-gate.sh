#!/bin/bash
# 孔明エージェントチーム — 品質ゲート
# PreToolUse(Write|Edit) で呼ばれ、重要ファイルの直接編集をブロック
#
# ブロック対象:
#   - .agents/TEAM.md（チーム設定は手動管理）
#   - .agents/tachikoma/waves/wave-plan-*.md（計画は /tachikoma-plan 経由で更新）

# Claude Code はフック情報を stdin の JSON で渡す（環境変数ではない）
INPUT=$(cat)
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# TEAM.md の直接編集をブロック（セットアップ時の編集は除外）
if echo "$FILE_PATH" | grep -qE '\.agents/TEAM\.md$'; then
  echo "⚠️ .agents/TEAM.md はチーム設定ファイルです。手動で編集してください。" >&2
  exit 2
fi

# checkpoint ファイルの直接編集をブロック（checkpoint.sh 経由で更新すべき）
if echo "$FILE_PATH" | grep -qE '\.agents/tachikoma/checkpoints/'; then
  echo "⚠️ checkpoint ファイルは checkpoint.sh 経由で更新してください。" >&2
  exit 2
fi

exit 0
