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
| 技術リード | tech-lead | 技術設計・実装 | opus |
| レビュアー | devils-advocate | 全成果物のレビュー・問題提起 | opus |

## Skills（スラッシュコマンド）

### メインワークフロー

| コマンド | 担当 | 用途 |
|---------|------|------|
| `/koumei-start {要件}` | koumei | タスク定義＋各担当への指示書を一括作成 |
| `/koumei-analyze [タスクID]` | analyst | 既存コード・スキーマの分析 |
| `/koumei-design [タスクID]` | ux-designer + tech-lead | UX設計と技術設計を**並列実行** |
| `/koumei-review [タスクID]` | devils-advocate | 全成果物のレビュー |
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

## セットアップ

### 方法1: セットアップスクリプト

```bash
bash scripts/setup.sh /path/to/your/project
```

### 方法2: 手動コピー

```bash
cp -r templates/.agents /path/to/your/project/
cp -r templates/.claude /path/to/your/project/
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

委譲先で実装したコードも、次の `/koumei-review` で必ずClaude（devils-advocate）がレビューするため品質は担保される。

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

## ディレクトリ構造

```
your-project/
├── .claude/
│   └── skills/                         # スキル定義
│       ├── koumei-start/SKILL.md
│       ├── koumei-analyze/SKILL.md
│       ├── koumei-design/SKILL.md      # 並列実行オーケストレーター
│       ├── koumei-design-ux/SKILL.md
│       ├── koumei-design-tech/SKILL.md
│       ├── koumei-review/SKILL.md
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
│   └── custom-roles/                   # カスタムロールテンプレート
│       ├── api-designer/CLAUDE.md
│       ├── data-engineer/CLAUDE.md
│       └── infra-architect/CLAUDE.md
```

## License

MIT
