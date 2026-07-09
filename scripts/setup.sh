#!/bin/bash
# 諸葛孔明エージェントチーム - プロジェクト展開スクリプト
#
# 使い方:
#   bash scripts/setup.sh /path/to/your/project
#
# テンプレートをコピーした後、プレースホルダーの置換は手動で行ってください。

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "エラー: ディレクトリ '$TARGET_DIR' が存在しません"
  exit 1
fi

if [ -d "$TARGET_DIR/.agents" ]; then
  echo "警告: '$TARGET_DIR/.agents' は既に存在します"
  read -p "上書きしますか？ (y/N): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "中止しました"
    exit 0
  fi
fi

echo "=== 諸葛孔明エージェントチーム セットアップ ==="
echo "対象: $TARGET_DIR"
echo ""

# テンプレートをコピー（既存ディレクトリがある場合は中身をマージ）
mkdir -p "$TARGET_DIR/.agents" "$TARGET_DIR/.claude/skills"
cp -r "$TEMPLATE_DIR/.agents/." "$TARGET_DIR/.agents/"
cp -r "$TEMPLATE_DIR/.claude/skills/." "$TARGET_DIR/.claude/skills/"

# hooks スクリプトをコピー
if [ -d "$TEMPLATE_DIR/hooks" ]; then
  echo "hooks/ をコピー中..."
  cp -r "$TEMPLATE_DIR/hooks" "$TARGET_DIR/hooks"
  chmod +x "$TARGET_DIR/hooks/"*.sh 2>/dev/null
fi

# .claude/settings.json をマージ（既存があれば hooks のみ追加）
if [ -f "$TEMPLATE_DIR/.claude/settings.json" ]; then
  mkdir -p "$TARGET_DIR/.claude"
  if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
    echo ".claude/settings.json が既に存在します。hooks をマージ中..."
    # jq で既存設定に hooks をマージ（既存の hooks がなければ追加、あればスキップ）
    if command -v jq >/dev/null 2>&1; then
      EXISTING="$TARGET_DIR/.claude/settings.json"
      TEMPLATE="$TEMPLATE_DIR/.claude/settings.json"
      MERGED=$(jq -s '.[0] * {hooks: (.[0].hooks // {} | to_entries + (.[1].hooks // {} | to_entries) | group_by(.key) | map({key: .[0].key, value: [.[] | .value[]] | unique}) | from_entries)}' "$EXISTING" "$TEMPLATE" 2>/dev/null)
      if [ $? -eq 0 ] && [ -n "$MERGED" ]; then
        echo "$MERGED" > "$EXISTING"
        echo "  hooks をマージしました"
      else
        echo "  ⚠️ マージに失敗。手動で .claude/settings.json に hooks を追加してください"
        echo "  テンプレート: $TEMPLATE"
      fi
    else
      echo "  ⚠️ jq が未インストール。手動で hooks を追加してください"
      echo "  テンプレート: $TEMPLATE_DIR/.claude/settings.json"
    fi
  else
    cp "$TEMPLATE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
    echo ".claude/settings.json を作成しました"
  fi
fi

echo ""
echo "展開完了！"
echo ""
echo "次のステップ:"
echo "  1. .agents/TEAM.md を編集（プロジェクト情報、アーキテクチャ、開発規約）"
echo "  2. 各 CLAUDE.md のプレースホルダー（{{...}}）を置換"
echo "  3. hooks/ と .claude/settings.json を確認（必要に応じてカスタマイズ）"
echo "  4. .agents/koumei/tasks/task-001.md で最初のタスクを定義"
echo ""
echo "プレースホルダー一覧:"
echo "  {{PROJECT_NAME}}       - プロジェクト名"
echo "  {{PROJECT_PATH}}       - プロジェクトのルートパス"
echo "  {{PROJECT_1}}          - 対象プロジェクト名1"
echo "  {{PROJECT_1_PATH}}     - 対象プロジェクトパス1"
echo "  {{FRAMEWORK_1}}        - フレームワーク名1"
echo "  {{ROLE_1}}             - プロジェクトの役割1"
echo "  {{TECH_STACK_1}}       - 主要技術スタック1"
echo "  {{UI_FRAMEWORK}}       - UIフレームワーク"
echo "  {{STYLING}}            - スタイリング手法"
echo "  {{EXISTING_COMPONENTS}} - 既存コンポーネント"
echo "  {{FRAMEWORK}}          - メインフレームワーク"
