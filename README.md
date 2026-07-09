# Koumei - Claude Code マルチエージェント開発テンプレート

Claude Codeのマルチエージェント開発体制を、任意のプロジェクトに展開するためのテンプレート集。

## 概要

諸葛孔明（最高指揮者）を頂点に、分析・UX設計・技術実装・レビューの4担当がチームとして機能開発を行う。
全ての指示出しは `/koumei-*` スキルコマンドで実行するため、ロールの切り替えは不要。

```
        ┌──────────────┐
        │  諸葛孔明     │  タスク定義・指示・最終判断
        │  (koumei)    │
        └──────┬───────┘
               │
    ┌──────────┼──────────┐
    │          │          │
┌───┴───┐ ┌───┴───┐ ┌───┴───┐
│analyst│ │  ux-  │ │ tech- │  /koumei-design で並列実行
│       │ │designer│ │ lead  │
└───┬───┘ └───┬───┘ └───┬───┘
    │         │         │
    └─────────┼─────────┘
              │
      ┌───────┴───────┐
      │   devils-     │  レビューフェーズ
      │   advocate    │
      └───────────────┘
```

### チーム構成

| 役割 | コードネーム | 責務 | モデル |
|------|------------|------|--------|
| 最高指揮者 | koumei | 全体統括、タスク分割、指示出し、最終判断 | sonnet |
| システム分析 | analyst | 既存コード・API・DB分析 | sonnet |
| UXデザイン | ux-designer | UI設計、画面遷移設計、レスポンシブ対応 | sonnet |
| 技術リード | tech-lead | 技術設計・実装 | fable（設計）/ opus（実装） |
| レビュアー | devils-advocate | 全成果物のレビュー・問題提起 | fable |
| タスク並列実行（オプション） | task-manager | マルチタスク時に1タスクのPhase 1〜7をworktree内で完遂 | inherit |

**モデル戦略**: 高単価・高知能モデル（fable）は「トークン量が多い場所」ではなく「判断のレバレッジが高く出力が小さい場所」に配置する。レビューVERDICTはフロー全体を制御する品質ゲートのため devils-advocate に、設計ミスは実装で増幅されるため tech-lead の設計フェーズに fable を使い、トークン量の多い実装は opus（または Codex 委譲）で実行する。モデルは `TEAM.md` のチーム構成テーブルの「モデル」列で一元管理され、オーケストレーターがサブエージェント起動時に `model` パラメータとして渡す。なお `/koumei-review` は既定で codex を優先するため（「レビューモデル選択」参照）、fable が使われるのは Claude でレビューを実行する経路。

## Skills（スラッシュコマンド）

### メインワークフロー

| コマンド | 担当 | 用途 |
|---------|------|------|
| `/koumei-start {要件}` | koumei | タスク定義＋各担当への指示書を一括作成（全自動/`--manual` 順次/`--multi` マルチタスク） |
| `/koumei-analyze [タスクID]` | analyst | 既存コード・スキーマの分析 |
| `/koumei-design [タスクID]` | ux-designer + tech-lead | UX設計と技術設計を**並列実行** |
| `/koumei-review [タスクID]` | devils-advocate | 全成果物のレビュー（`--security` / `--second-opinion` / `--model` で拡張） |
| `/koumei-implement [フェーズ番号]` | tech-lead | レビュー通過後、実装を開始 |
| `/koumei-status` | koumei | タスク進捗の確認・次アクション提案 |

### 個別実行（差し戻し時）

| コマンド | 担当 | 用途 |
|---------|------|------|
| `/koumei-design-ux [タスクID]` | ux-designer | UX設計のみ単独実行 |
| `/koumei-design-tech [タスクID]` | tech-lead | 技術設計のみ単独実行 |

### 典型的な流れ

```
/koumei-start メモ帳機能     ← タスク定義＋指示書作成
/koumei-analyze              ← 既存コード分析
/koumei-design               ← UX設計 + 技術設計（並列実行）
/koumei-review               ← レビュー実行
/koumei-implement            ← 実装開始
/koumei-review               ← コードレビュー
/koumei-status               ← 最終進捗確認

※ 迷ったら /koumei-status で次のアクションを確認
```

## ワークフロー

```
【設計フェーズ】
1. /koumei-start {要件}       → タスク定義・指示書を自動生成
2. /koumei-analyze             → 既存システム分析
3. /koumei-design              → UX設計 + 技術設計を並列実行
4. /koumei-review              → 全成果物レビュー
   → 差し戻し: /koumei-design-ux or /koumei-design-tech → /koumei-review

【実装フェーズ】
5. /koumei-implement           → 実装（レビュー通過後のみ）
6. /koumei-review              → コードレビュー

【検証フェーズ】
7. /koumei-status              → 最終進捗確認
8. 動作確認 → メインブランチへ PR
```

### タスク種別による短縮フロー

`/koumei-start` はタスク種別を判定し、不要なフェーズを自動でスキップする。

| 種別 | フロー |
|------|--------|
| 軽微修正（クイック） | 定義(簡易)→実装→コードレビュー→PR（分析・設計をスキップ） |
| バグ修正（小） | 定義→分析→分析レビュー→実装→コードレビュー→PR（設計をスキップ） |
| バグ修正（中） | フルフローからUX設計のみスキップ可 |
| 機能追加/移植 | フルフロー |

**コードレビューはいかなる種別でもスキップされない**（品質担保の不変則）。

## セットアップ

### 方法1: セットアップスクリプト（推奨）

```bash
bash scripts/setup.sh /path/to/your/project
```

`.agents` / `.claude/skills` のコピーに加え、hooks/ のコピーと `.claude/settings.json` のマージ（既存設定があれば hooks のみ追加）まで自動で行う。

### 方法2: 手動コピー

```bash
cp -r templates/.agents /path/to/your/project/
cp -r templates/.claude /path/to/your/project/
cp -r templates/hooks /path/to/your/project/   # Hooks を使う場合
```

### カスタマイズ

1. **`.agents/TEAM.md`** を編集 — プロジェクト名、対象リポジトリ、アーキテクチャ、開発規約
2. **各担当の `CLAUDE.md`** のプレースホルダーを置換:

| プレースホルダー | 内容 |
|----------------|------|
| `{{PROJECT_NAME}}` | プロジェクト名 |
| `{{PROJECT_PATH}}` | プロジェクトのルートパス |
| `{{PROJECT_1}}` / `{{PROJECT_1_PATH}}` | 対象プロジェクト名・パス |
| `{{FRAMEWORK}}` / `{{FRAMEWORK_1}}` | フレームワーク |
| `{{UI_FRAMEWORK}}` | UIフレームワーク |
| `{{STYLING}}` | スタイリング手法 |
| `{{EXISTING_COMPONENTS}}` | 既存コンポーネント |

## 拡張機能

### マルチタスク並列実行

`/koumei-start {要件} --multi` で、独立した複数タスクを並列に完遂できる。

```
        ┌──────────────┐
        │  諸葛孔明     │  要件分割・実行計画・結果集約
        └──────┬───────┘
    ┌──────────┼──────────┐
┌───┴────┐ ┌───┴────┐ ┌───┴────┐
│task-mgr│ │task-mgr│ │task-mgr│  タスクごとの部将（並列）
│task-1  │ │task-2  │ │task-3  │  各自 worktree で Phase 1〜7 → PR
└────────┘ └────────┘ └────────┘
```

- 孔明が要件を「1タスク=1ブランチ=1PR」の単位に分割し、依存・ファイル競合を判定して並列/直列の実行計画を立てる（実行前にユーザー承認）
- 各 task-manager は git worktree 内で分析〜PR作成までを完遂する（レビュー独立の厳格ルールも通常フローと同一）
- task-manager はユーザーに質問できないため、3回差し戻し等の判断事項は HALTED として孔明に返り、孔明がまとめてユーザーに諮る
- 前提: Claude Code v2.1.172 以降（サブエージェントのネスト起動）

単一タスクや逐次実行なら task-manager は不要で、孔明が直接統括する（デフォルト動作）。

### カスタムロール

プロジェクト特性に応じて追加ロールを定義できる。テンプレートは `templates/.agents/custom-roles/` に用意済み。

- `api-designer` — API設計担当
- `data-engineer` — データエンジニアリング担当
- `infra-architect` — インフラ設計担当

追加手順:
1. `.agents/{ロール名}/CLAUDE.md` を作成
2. `TEAM.md` のチーム構成テーブルにロールを追記

### モデル委譲（Claudeトークン節約）

サブエージェントの一部をCodex等の外部モデルに委譲し、Claudeトークンを節約できる。

有効化: `TEAM.md` 内のモデル委譲設定テーブルのコメントを外す。

```markdown
| 役割 | 委譲先 | 呼び出し方法 | 対象フェーズ |
|------|--------|------------|------------|
| analyst | codex | `codex -q "{プロンプト}"` | 分析（/koumei-analyze） |
| tech-lead | codex | `codex -q "{プロンプト}"` | 実装（/koumei-implement） |
```

**委譲推奨:**
- **analyst** — コード分析はCodexの得意領域。読み取り中心で品質リスク低
- **tech-lead（実装）** — コーディング能力が高い。opus→Codexで大幅節約

**Claude維持推奨:**
- **koumei** — オーケストレーター（Claude Agent API必須）
- **ux-designer** — 創造的UX判断が多い
- **devils-advocate** — 品質ゲートは信頼性重視

委譲先で実装したコードも、次の `/koumei-review` の独立レビューを必ず通るため品質は担保される（レビュー実行モデルは「レビューモデル選択」に従う）。

### レビューモデル選択（codex優先・自動フォールバック）

`/koumei-review` は `TEAM.md` の「レビューモデル設定」（`review_mode`）に従い、レビューを実行するモデルを選択する。

| モード | 優先順位 |
|--------|---------|
| `default` | codex → claude |
| `economy` | codex → lmstudio → claude |
| `claude-only` | claude のみ |

- claude で実行する場合は devils-advocate エージェントに委譲する（モデルはチーム構成の「モデル」列。既定: fable）
- **遅い場合の自動切り替え**: `review_timeout`（秒。既定: 600）を超えたら中断し、次の優先モデルへ自動フォールバックする。フォールバック理由はユーザー報告とレビュー結果に記録される
- **一時切り替え**: `/koumei-review --model claude` のように指定すると、TEAM.md を編集せずそのレビューだけモデルを強制できる

### セカンドオピニオン（クロスモデルレビュー）

Devil's Advocateレビュー時に、Claude以外のモデル（Codex, Gemini等）によるセカンドオピニオンを取得可能。

有効化: `TEAM.md` 内のセカンドオピニオン設定テーブルのコメントを外す。

```markdown
| モデル名 | プロバイダー | 呼び出し方法 |
|---------|------------|------------|
| codex | OpenAI | `codex -q "{プロンプト}"` |
| gemini | Google | `gemini "{プロンプト}"` |
```

未設定の場合は通常のClaude単独レビューとして動作する。

### Claude Code Hooks（自動化テンプレート）

`templates/hooks/` と `templates/.claude/settings.json` に、展開先プロジェクト用の Hooks 一式を用意。`setup.sh` が hooks/ のコピーと settings.json のマージ（要 jq）まで自動で行う。

| フック | タイミング | 内容 |
|--------|-----------|------|
| `quality-gate.sh` | PreToolUse (Write/Edit) | `TEAM.md` 等の重要ファイルの直接編集をブロック |
| `log-operation.sh` | PostToolUse (全ツール) | 全操作を `.agents/logs/YYYY-MM-DD.jsonl` に記録 |
| `auto-format.sh` | PostToolUse (Write/Edit) | prettier があれば対象ファイルを自動フォーマット（.md は除外） |
| `notify-phase.sh` | PostToolUse (Write) | 成果物・レビュー・完了報告の書き込みを検知して macOS 通知 |

## ディレクトリ構造

```
your-project/
├── .claude/
│   ├── settings.json                   # Hooks 設定（setup.sh がマージ）
│   └── skills/                         # スキル定義
│       ├── koumei-start/
│       │   ├── SKILL.md
│       │   └── docs/                   # phases / rules / error-handling /
│       │                               #  task-template / multi-task
│       ├── koumei-analyze/SKILL.md
│       ├── koumei-design/SKILL.md      # 並列実行オーケストレーター
│       ├── koumei-design-ux/SKILL.md
│       ├── koumei-design-tech/SKILL.md
│       ├── koumei-review/
│       │   ├── SKILL.md
│       │   └── docs/                   # extended-modes（セキュリティ監査/セカンド
│       │                               #  オピニオン）/ review-models（モデル選択）
│       ├── koumei-implement/SKILL.md
│       └── koumei-status/SKILL.md
├── .agents/
│   ├── TEAM.md                         # チーム構成・規約
│   ├── koumei/
│   │   ├── CLAUDE.md                   # 最高指揮者の役割定義
│   │   ├── tasks/                      # タスク定義
│   │   └── reports/                    # 各担当からの完了報告
│   ├── analyst/
│   │   ├── CLAUDE.md
│   │   ├── instructions/               # 孔明からの指示書
│   │   └── deliverables/               # 分析成果物
│   ├── ux-designer/
│   │   ├── CLAUDE.md
│   │   ├── instructions/
│   │   └── deliverables/
│   ├── tech-lead/
│   │   ├── CLAUDE.md
│   │   ├── instructions/
│   │   └── deliverables/
│   ├── devils-advocate/
│   │   ├── CLAUDE.md
│   │   ├── instructions/
│   │   └── reviews/                    # レビュー結果
│   ├── task-manager/
│   │   └── CLAUDE.md                   # マルチタスク時の実行単位（部将）
│   └── custom-roles/                   # カスタムロールテンプレート
│       ├── api-designer/CLAUDE.md
│       ├── data-engineer/CLAUDE.md
│       └── infra-architect/CLAUDE.md
├── hooks/                              # Claude Code Hooks
│   ├── quality-gate.sh                 # 重要ファイルの直接編集ブロック
│   ├── log-operation.sh                # 全操作のログ記録
│   ├── auto-format.sh                  # 保存時の自動フォーマット
│   └── notify-phase.sh                 # フェーズ完了の通知
```

## License

MIT
