#!/bin/bash
# 諸葛孔明エージェントチーム - プロジェクト展開スクリプト
#
# 使い方:
#   bash scripts/setup.sh /path/to/your/project
#   bash scripts/setup.sh -y /path/to/your/project
#   KOUMEI_FORCE=1 bash scripts/setup.sh /path/to/your/project
#
# テンプレートをコピーした後、プレースホルダーの置換は手動で行ってください。

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"
TARGET_DIR="."
FORCE=0

usage() {
  cat <<'EOF'
Usage: bash scripts/setup.sh [options] [target-dir]

Install the Koumei multi-agent template into a project (Claude Code + Grok Build).

Options:
  -y, --yes     Non-interactive. Overwrite/merge without prompting
                (same as KOUMEI_FORCE=1)
  -h, --help    Show this help

Environment:
  KOUMEI_FORCE=1   Same as -y / --yes

Copies:
  templates/.agents            -> <target>/.agents
  templates/.claude/skills     -> <target>/.claude/skills
  <target>/.claude/skills      -> <target>/.grok/skills  (Grok-native mirror)
  templates/hooks              -> <target>/hooks
  templates/.claude/settings.json  (create or merge hooks)
  templates/AGENTS.md          -> <target>/AGENTS.md (if missing)
  templates/.grok/HOOKS.md     -> <target>/.grok/HOOKS.md
EOF
}

if [ "${KOUMEI_FORCE:-}" = "1" ]; then
  FORCE=1
fi

for arg in "$@"; do
  case "$arg" in
    -y|--yes)
      FORCE=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "エラー: 不明なオプション '$arg'"
      usage
      exit 1
      ;;
    *)
      TARGET_DIR="$arg"
      ;;
  esac
done

if [ ! -d "$TARGET_DIR" ]; then
  echo "エラー: ディレクトリ '$TARGET_DIR' が存在しません"
  exit 1
fi

if [ -d "$TARGET_DIR/.agents" ]; then
  echo "警告: '$TARGET_DIR/.agents' は既に存在します"
  if [ "$FORCE" -eq 1 ]; then
    echo "非対話モード (-y / KOUMEI_FORCE=1): テンプレートをマージコピーします（既存のタスク成果物は残します）"
  else
    if [ -t 0 ]; then
      read -p "上書きしますか？ (y/N): " confirm
      if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "中止しました"
        exit 0
      fi
    else
      echo "エラー: TTY がありません。非対話実行するには -y または KOUMEI_FORCE=1 を指定してください"
      exit 1
    fi
  fi
fi

echo "=== 諸葛孔明エージェントチーム セットアップ ==="
echo "対象: $TARGET_DIR"
echo ""

# テンプレートをコピー（既存ディレクトリがある場合は中身をマージ）
mkdir -p "$TARGET_DIR/.agents" "$TARGET_DIR/.claude/skills"
cp -r "$TEMPLATE_DIR/.agents/." "$TARGET_DIR/.agents/"
cp -r "$TEMPLATE_DIR/.claude/skills/." "$TARGET_DIR/.claude/skills/"

# Grok-native skill discovery: mirror Claude skills into .grok/skills
echo ".grok/skills/ にスキルをミラー中..."
mkdir -p "$TARGET_DIR/.grok/skills"
cp -r "$TARGET_DIR/.claude/skills/." "$TARGET_DIR/.grok/skills/"

# hooks スクリプトをコピー
if [ -d "$TEMPLATE_DIR/hooks" ]; then
  echo "hooks/ をコピー中..."
  mkdir -p "$TARGET_DIR/hooks"
  cp -r "$TEMPLATE_DIR/hooks/." "$TARGET_DIR/hooks/"
  chmod +x "$TARGET_DIR/hooks/"*.sh 2>/dev/null || true
fi

# Grok hooks の説明（Claude settings.json hooks との違い）
if [ -f "$TEMPLATE_DIR/.grok/HOOKS.md" ]; then
  mkdir -p "$TARGET_DIR/.grok"
  cp "$TEMPLATE_DIR/.grok/HOOKS.md" "$TARGET_DIR/.grok/HOOKS.md"
  echo ".grok/HOOKS.md を作成しました（Grok /hooks-trust と Claude settings.json の違い）"
fi

# オーケストレーター向け AGENTS.md（既存があれば上書きしない）
if [ -f "$TEMPLATE_DIR/AGENTS.md" ]; then
  if [ -f "$TARGET_DIR/AGENTS.md" ]; then
    echo "AGENTS.md は既に存在します。上書きしません"
  else
    cp "$TEMPLATE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
    echo "AGENTS.md を作成しました"
  fi
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
      MERGED=$(jq -s '.[0] * {hooks: (.[0].hooks // {} | to_entries + (.[1].hooks // {} | to_entries) | group_by(.key) | map({key: .[0].key, value: [.[] | .value[]] | unique}) | from_entries)}' "$EXISTING" "$TEMPLATE" 2>/dev/null) || true
      if [ -n "$MERGED" ]; then
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
echo "  4. Grok Build を使う場合は .grok/HOOKS.md を読み、必要なら /hooks-trust"
echo "  5. .agents/koumei/tasks/task-001.md で最初のタスクを定義"
echo ""
echo "Claude Code: プロジェクトで claude を起動し /koumei-start を実行"
echo "Grok Build:  プロジェクトで grok を起動し /koumei-start または /skills koumei-start"
echo ""
echo "プレースホルダー一覧:"
echo "  {{PROJECT_NAME}}       - プロジェクト名"
echo "  {{PROJECT_PATH}}       - プロジェクトのルートパス"
echo "  {{PROJECT_1}}          - 対象プロジェクト名1"
echo "  {{PROJECT_1_PATH}}     - 対象プロジェクトパス1"
echo "  {{FRAMEWORK_1}}        - フレームワーク名1"
echo "  {{ROLE_1}}             - プロジェクトの役割1"
echo "  {{TECH_STACK_1}}       - 主要技術スタック1"
echo "  {{PROJECT_2}}          - 対象プロジェクト名2"
echo "  {{PROJECT_2_PATH}}     - 対象プロジェクトパス2"
echo "  {{FRAMEWORK_2}}        - フレームワーク名2"
echo "  {{ROLE_2}}             - プロジェクトの役割2"
echo "  {{UI_FRAMEWORK}}       - UIフレームワーク"
echo "  {{STYLING}}            - スタイリング手法"
echo "  {{EXISTING_COMPONENTS}} - 既存コンポーネント"
echo "  {{FRAMEWORK}}          - メインフレームワーク"
