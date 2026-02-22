# 諸葛孔明エージェントチーム - 汎用テンプレート

Claude Codeのマルチエージェント開発体制を、任意のプロジェクトに展開するためのテンプレート集。

## 概要

諸葛孔明（最高指揮者）を頂点に、分析・UX設計・技術実装・レビューの4担当がチームとして機能開発を行う体制。
全ての指示出しは `/koumei-*` スキルコマンドで実行するため、ロールの切り替えは不要。
設計フェーズでは `/koumei-design` がux-designerとtech-leadを**並列起動**し、効率的に進行する。

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

## Skills（スラッシュコマンド）

スキルコマンドでワークフローの全ステップを実行する。

### メインワークフロー

| コマンド | 担当 | 用途 |
|---------|------|------|
| `/koumei-start {要件}` | 孔明 | タスク定義＋各担当への指示書を一括作成 |
| `/koumei-analyze [タスクID]` | analyst | 既存コード・スキーマの分析を実行 |
| `/koumei-design [タスクID]` | **ux-designer + tech-lead** | UX設計と技術設計を**並列実行** |
| `/koumei-review [タスクID]` | devils-advocate | 全成果物のレビューを実行 |
| `/koumei-implement [フェーズ番号]` | tech-lead | レビュー通過後、実装を開始 |
| `/koumei-status` | 孔明 | タスク進捗の確認・次アクション提案 |

### 個別実行（差し戻し時の再実行用）

| コマンド | 担当 | 用途 |
|---------|------|------|
| `/koumei-design-ux [タスクID]` | ux-designer | UX設計のみ単独実行 |
| `/koumei-design-tech [タスクID]` | tech-lead | 技術設計のみ単独実行 |

### 典型的な使い方

```
/koumei-start テンプレートメモ帳機能    ← タスク定義＋指示書作成
/koumei-analyze                        ← 既存コード分析
/koumei-design                         ← UX設計 + 技術設計（並列実行）
/koumei-review                         ← レビュー実行
/koumei-implement                      ← 実装開始
/koumei-review                         ← コードレビュー
/koumei-status                         ← 最終進捗確認

※ 迷ったら /koumei-status で次のアクションを確認
```

## プロジェクトへの展開手順

### 1. テンプレートをコピー

```bash
# .agents（ワークスペース）と .claude/skills（スキル定義）の両方をコピー
cp -r templates/.agents /path/to/your/project/
cp -r templates/.claude /path/to/your/project/
```

### 2. TEAM.md をカスタマイズ

`.agents/TEAM.md` を開き、以下を自プロジェクトに合わせて編集:

- **プロジェクト名・概要**
- **対象プロジェクトテーブル**: パス、フレームワーク、役割を記載
- **通信アーキテクチャ**: クライアント→API→DB等の構成図
- **開発規約**: プロジェクト固有のルール

### 3. 各担当の CLAUDE.md をカスタマイズ

最低限編集が必要な箇所:

| ファイル | 編集箇所 |
|---------|---------|
| `koumei/CLAUDE.md` | 参照ドキュメントのパス、対象プロジェクト |
| `analyst/CLAUDE.md` | 分析対象プロジェクトのパス・技術スタック |
| `ux-designer/CLAUDE.md` | UIフレームワーク、デザインシステム、既存コンポーネント |
| `tech-lead/CLAUDE.md` | 対象プロジェクトの技術スタック詳細 |
| `devils-advocate/CLAUDE.md` | レビュー観点のプロジェクト固有項目 |

各ファイルに `{{PROJECT_PATH}}` 等のプレースホルダーがあるので、実際のパスに置換する。

### 4. スキルで開始

```
/koumei-start テンプレートメモ帳機能
```

タスク定義と全担当への指示書が自動生成される。以降は各スキルの完了時に次のステップが案内される。

## ワークフロー（スキル駆動）

```
【設計フェーズ】
1. /koumei-start {要件}       → タスク定義・指示書を自動生成
2. /koumei-analyze             → 既存システム分析
3. /koumei-design              → UX設計 + 技術設計を並列実行
4. /koumei-review              → 全成果物レビュー
   → 差し戻し: /koumei-design-ux or /koumei-design-tech で個別再実行 → /koumei-review

【実装フェーズ】
5. /koumei-implement           → 実装（レビュー通過後のみ実行可能）
6. /koumei-review              → コードレビュー

【検証フェーズ】
7. /koumei-status              → 最終進捗確認
8. 動作確認 → メインブランチへ PR
```

## ディレクトリ構造

```
your-project/
├── .claude/
│   └── skills/                         # スキル定義（プロジェクト固有）
│       ├── koumei-start/SKILL.md
│       ├── koumei-analyze/SKILL.md
│       ├── koumei-design/SKILL.md      # オーケストレーター（並列実行）
│       ├── koumei-design-ux/SKILL.md   # 個別実行用
│       ├── koumei-design-tech/SKILL.md # 個別実行用
│       ├── koumei-review/SKILL.md
│       ├── koumei-implement/SKILL.md
│       └── koumei-status/SKILL.md
├── .agents/
│   ├── TEAM.md                          # チーム構成・スキルコマンド一覧・規約
│   ├── koumei/
│   │   ├── CLAUDE.md                    # 最高指揮者の役割定義
│   │   ├── tasks/                       # タスク定義
│   │   │   └── task-001.md
│   │   └── reports/                     # 各担当からの完了報告
│   │       └── task-001-analyst-report.md
│   ├── analyst/
│   │   ├── CLAUDE.md                    # 分析担当の役割定義
│   │   ├── instructions/                # 孔明からの指示書
│   │   │   └── task-001-instruction.md
│   │   └── deliverables/                # 分析成果物
│   │       └── task-001-analysis.md
│   ├── ux-designer/
│   │   ├── CLAUDE.md
│   │   ├── instructions/
│   │   └── deliverables/
│   ├── tech-lead/
│   │   ├── CLAUDE.md
│   │   ├── instructions/
│   │   └── deliverables/
│   └── devils-advocate/
│       ├── CLAUDE.md
│       ├── instructions/
│       └── reviews/                     # レビュー結果
│           └── task-001-review.md
```

## 適用実績

| プロジェクト | 用途 | 備考 |
|------------|------|------|
| （社内プロジェクトA） | フレームワーク移植 | 初回適用 |
| （社内プロジェクトB） | 機能開発 | 複数プロジェクト横断 |
