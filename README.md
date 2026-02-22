# 諸葛孔明エージェントチーム - 汎用テンプレート

Claude Codeのマルチエージェント開発体制を、任意のプロジェクトに展開するためのテンプレート集。

## 概要

諸葛孔明（最高指揮者）を頂点に、分析・UX設計・技術実装・レビューの4担当がチームとして機能開発を行う体制。

```
        ┌──────────────┐
        │  諸葛孔明     │  タスク定義・指示・最終判断
        │  (koumei)    │
        └──────┬───────┘
               │
    ┌──────────┼──────────┐
    │          │          │
┌───┴───┐ ┌───┴───┐ ┌───┴───┐
│analyst│ │  ux-  │ │ tech- │  設計フェーズ（並列）
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

## プロジェクトへの展開手順

### 1. テンプレートをコピー

```bash
cp -r templates/.agents /path/to/your/project/.agents
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

### 4. 最初のタスクを定義

```bash
vi .agents/koumei/tasks/task-001.md
```

以下を記載:
- タスク概要
- 要件定義書へのリンク
- 影響範囲（ファイル・コレクション）
- 実装フェーズ
- 各担当への指示概要

### 5. 設計フェーズ開始

孔明として各担当に指示書を配置:

```bash
# 例: analystへの指示
vi .agents/analyst/instructions/task-001-instruction.md
```

## ワークフロー詳細

```
【設計フェーズ】
1. 孔明がタスクを定義        → .agents/koumei/tasks/
2. 孔明が各担当に指示書を配置 → .agents/{担当}/instructions/
3. analyst が既存システム分析  → .agents/analyst/deliverables/
4. ux-designer と tech-lead が並列で設計 → 各 deliverables/
5. 各担当が完了報告           → .agents/koumei/reports/
6. 悪魔の代弁者がレビュー     → .agents/devils-advocate/reviews/
7. 孔明がレビュー結果を確認   → 修正指示 or 承認

【実装フェーズ】
8. 全ドキュメント承認後       → tech-lead が実装開始
9. 実装完了                   → ビルド成功を確認
10. 悪魔の代弁者がコードレビュー → 指摘修正

【検証フェーズ】
11. 開発サーバーでの動作確認（孔明が実施）
12. 孔明が最終確認            → メインブランチへ PR
```

## ディレクトリ構造

```
.agents/
├── TEAM.md                          # チーム構成・ワークフロー・規約
├── koumei/
│   ├── CLAUDE.md                    # 最高指揮者の役割定義
│   ├── tasks/                       # タスク定義
│   │   └── task-001.md
│   └── reports/                     # 各担当からの完了報告
│       └── task-001-analyst-report.md
├── analyst/
│   ├── CLAUDE.md                    # 分析担当の役割定義
│   ├── instructions/                # 孔明からの指示書
│   │   └── task-001-instruction.md
│   └── deliverables/                # 分析成果物
│       └── task-001-analysis.md
├── ux-designer/
│   ├── CLAUDE.md
│   ├── instructions/
│   └── deliverables/
├── tech-lead/
│   ├── CLAUDE.md
│   ├── instructions/
│   └── deliverables/
└── devils-advocate/
    ├── CLAUDE.md
    ├── instructions/
    └── reviews/                     # レビュー結果
        └── task-001-review.md
```

## Skills（スラッシュコマンド）

孔明チームの各フェーズをスラッシュコマンドで実行できるSkillsを提供。
`~/.claude/skills/` に配置済み（全プロジェクト共通で使用可能）。

### コマンド一覧

| コマンド | 担当 | 用途 |
|---------|------|------|
| `/koumei-start` | 孔明 | タスク定義＋各担当への指示書を一括作成 |
| `/koumei-analyze` | analyst | 既存コード・スキーマの分析を実行 |
| `/koumei-design-ux` | ux-designer | UI/UX設計を実行 |
| `/koumei-design-tech` | tech-lead | 技術設計書を作成 |
| `/koumei-review` | devils-advocate | 全成果物のレビューを実行 |
| `/koumei-implement` | tech-lead | レビュー通過後、実装を開始 |
| `/koumei-status` | 孔明 | タスク進捗の確認・次アクション提案 |

### 典型的な使い方

```
/koumei-start テンプレートメモ帳機能    ← タスク定義＋指示書作成
/koumei-analyze task-001               ← 既存コード分析
/koumei-design-ux task-001             ← UX設計
/koumei-design-tech task-001           ← 技術設計
/koumei-review task-001                ← レビュー実行
/koumei-implement task-001             ← 実装開始
/koumei-status                         ← 進捗確認
```

### Skills ファイルの配置先

```
~/.claude/skills/
├── koumei-start/SKILL.md
├── koumei-analyze/SKILL.md
├── koumei-design-ux/SKILL.md
├── koumei-design-tech/SKILL.md
├── koumei-review/SKILL.md
├── koumei-implement/SKILL.md
└── koumei-status/SKILL.md
```

## 適用実績

| プロジェクト | 用途 | 備考 |
|------------|------|------|
| （社内プロジェクトA） | フレームワーク移植 | 初回適用 |
| （社内プロジェクトB） | 機能開発 | 複数プロジェクト横断 |
