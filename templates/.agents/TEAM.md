# エージェントチーム構成

## プロジェクト: {{PROJECT_NAME}}

### チーム構成

| 役割 | コードネーム | ワークスペース | 責務 | モデル |
|------|------------|--------------|------|--------|
| **最高指揮者** | 諸葛孔明 (koumei) | `.agents/koumei/` | 全体統括、タスク分割、指示出し、最終判断 | sonnet |
| **システム分析担当** | analyst | `.agents/analyst/` | 既存コード・API・DB分析 | sonnet |
| **UXデザイン担当** | ux-designer | `.agents/ux-designer/` | UI設計、画面遷移設計、レスポンシブ対応 | sonnet |
| **技術アーキテクチャ&実装担当** | tech-lead | `.agents/tech-lead/` | 技術設計・実装 | **opus** |
| **悪魔の代弁者** | devils-advocate | `.agents/devils-advocate/` | 全成果物のレビュー・問題提起 | **opus** |

### ワークフロー

```
【設計フェーズ】
1. 孔明がタスクを定義 → .agents/koumei/tasks/
2. 孔明が各担当に指示書を配置 → .agents/{担当}/instructions/
3. analyst が既存システム分析 → .agents/analyst/deliverables/
4. ux-designer と tech-lead が並列で設計 → 各 deliverables/
5. 各担当が完了報告 → .agents/koumei/reports/
6. 悪魔の代弁者がレビュー → .agents/devils-advocate/reviews/
7. 孔明がレビュー結果を確認 → 修正指示 or 承認

【実装フェーズ】
8. 全ドキュメント承認後 → tech-lead が実装開始
9. 実装完了 → ビルド成功を確認
10. 悪魔の代弁者がコードレビュー → 指摘修正

【検証フェーズ】
11. 開発サーバーでの動作確認（孔明が実施）
12. 孔明が最終確認 → メインブランチへ PR
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
- レビュー: `{タスクID}-review.md` (例: `task-001-review.md`)
- 完了報告: `{タスクID}-{担当名}-report.md` (例: `task-001-analyst-report.md`)

### 開発規約

<!-- プロジェクト固有の開発規約を記載 -->

- コミットメッセージに自動生成マーカーやCo-Authored-Byを含めない
