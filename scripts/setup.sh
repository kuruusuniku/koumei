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

# テンプレートをコピー
cp -r "$TEMPLATE_DIR/.agents" "$TARGET_DIR/.agents"

echo "展開完了！"
echo ""
echo "次のステップ:"
echo "  1. .agents/TEAM.md を編集（プロジェクト情報、アーキテクチャ、開発規約）"
echo "  2. 各 CLAUDE.md のプレースホルダー（{{...}}）を置換"
echo "  3. .agents/koumei/tasks/task-001.md で最初のタスクを定義"
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
