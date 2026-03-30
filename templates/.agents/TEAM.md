# エージェントチーム構成

## プロジェクト: {{PROJECT_NAME}}

### スキルコマンド一覧

全ての指示出しはスキルコマンドで実行する。ロールの切り替えは不要。

| コマンド | 役割 | 説明 |
|---------|------|------|
| `/koumei-start {要件}` | 諸葛孔明 | タスク定義・全担当への指示書作成 |
| `/koumei-analyze [タスクID]` | analyst | 既存コードベースの分析 |
| `/koumei-design [タスクID]` | **ux-designer + tech-lead** | UX設計と技術設計を**並列実行** |
| `/koumei-review [タスクID]` | devils-advocate | 全成果物のレビュー |
| `/koumei-implement [フェーズ番号]` | tech-lead | 実装（レビュー通過後） |
| `/koumei-status` | 諸葛孔明 | 進捗確認・次のアクション提案 |

個別実行（差し戻し時の再実行用）:

| コマンド | 役割 | 説明 |
|---------|------|------|
| `/koumei-design-ux [タスクID]` | ux-designer | UX設計のみ単独実行 |
| `/koumei-design-tech [タスクID]` | tech-lead | 技術設計のみ単独実行 |

### チーム構成

| 役割 | コードネーム | ワークスペース | 責務 | モデル |
|------|------------|--------------|------|--------|
| **最高指揮者** | 諸葛孔明 (koumei) | `.agents/koumei/` | 全体統括、タスク分割、指示出し、最終判断 | sonnet |
| **システム分析担当** | analyst | `.agents/analyst/` | 既存コード・API・DB分析 | sonnet |
| **UXデザイン担当** | ux-designer | `.agents/ux-designer/` | UI設計、画面遷移設計、レスポンシブ対応 | sonnet |
| **技術アーキテクチャ&実装担当** | tech-lead | `.agents/tech-lead/` | 技術設計・実装 | **opus** |
| **悪魔の代弁者** | devils-advocate | `.agents/devils-advocate/` | 全成果物のレビュー・問題提起 | **opus** |

### カスタムロール（オプション）

プロジェクト特性に応じてカスタムロールを追加できます。以下のテンプレートを参考に定義してください。

<!-- 必要に応じてカスタムロールを追加 -->
<!-- | **カスタムロール名** | custom-role-name | `.agents/custom-role-name/` | 責務の説明 | sonnet | -->

#### カスタムロールの追加手順

1. `.agents/{ロール名}/CLAUDE.md` を作成（下記テンプレート参照）
2. 上記「チーム構成」テーブルにロールを追記
3. 必要に応じて `/koumei-start` の指示書生成にロールを含める

#### カスタムロール CLAUDE.md テンプレート

```text
# {ロール名} CLAUDE.md

## 役割
{このロールの責務を記載}

## 責務
1. {責務1}
2. {責務2}

## 成果物フォーマット
{成果物の形式を記載}

## ワークスペース
- 指示書: `.agents/{ロール名}/instructions/`
- 成果物: `.agents/{ロール名}/deliverables/`
- 完了報告: `.agents/koumei/reports/`
```

### セカンドオピニオン設定（オプション）

Devil's Advocateレビュー時に、Claude以外のモデルによるセカンドオピニオンを取得できます。

<!-- 必要に応じてセカンドオピニオンモデルを設定 -->
<!--
| モデル名 | プロバイダー | 呼び出し方法 |
|---------|------------|------------|
| codex | OpenAI | `codex -q "{プロンプト}"` |
| gemini | Google | `gemini "{プロンプト}"` |
-->

**有効化方法**: 上記テーブルのコメントを外し、使用するモデルを記載してください。
セカンドオピニオンが未設定の場合、`/koumei-review` は通常のClaude単独レビューとして動作します。

### ワークフロー（スキル駆動）

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

※ 迷ったら /koumei-status で次のアクションを確認
```

### 対象プロジェクト

<!-- 自プロジェクトに合わせて編集 -->

| プロジェクト | パス | フレームワーク | 役割 |
|------------|------|--------------|------|
| **{{PROJECT_1}}** | `{{PROJECT_1_PATH}}` | {{FRAMEWORK_1}} | {{ROLE_1}} |
| **{{PROJECT_2}}** | `{{PROJECT_2_PATH}}` | {{FRAMEWORK_2}} | {{ROLE_2}} |

### 通信アーキテクチャ

<!-- 自プロジェクトのアーキテクチャに合わせて編集 -->

```
[クライアント] --> [APIサーバー] --> [データベース]
```

### 指示書・報告書の命名規則

- タスク定義: `{タスクID}.md` (例: `task-001.md`)
- 指示書: `{タスクID}-instruction.md` (例: `task-001-instruction.md`)
- 成果物: `{タスクID}-{種類}.md` (例: `task-001-analysis.md`)
- 分析レビュー: `{タスクID}-analysis-review.md` (例: `task-001-analysis-review.md`)
- 設計レビュー: `{タスクID}-design-review.md` (例: `task-001-design-review.md`)
- コードレビュー: `{タスクID}-code-review.md` (例: `task-001-code-review.md`)
- 完了報告: `{タスクID}-{担当名}-report.md` (例: `task-001-analyst-report.md`)

### 開発規約

<!-- プロジェクト固有の開発規約を記載 -->

- コミットメッセージに自動生成マーカーやCo-Authored-Byを含めない
