# レビューモデル選択・実行手順

## モデル判定フロー

```
1. TEAM.md の review_mode を確認（未設定なら default）

2. review_mode に応じてモデルを選択:

   【default モード】
   a. codex スキルが利用可能か確認（/codex:review が存在するか）
      → 利用可能 → Codex でレビュー実行（手順A）
      → 利用不可 → Claude でレビュー実行（手順C）

   【economy モード】
   a. codex スキルが利用可能か確認
      → 利用可能 → Codex でレビュー実行（手順A）
   b. lmstudio-mcp が利用可能か確認（ToolSearch で mcp__lmstudio-mcp__chat_completion を検索）
      → 利用可能 → LM Studio でレビュー実行（手順B）
   c. いずれも不可 → Claude でレビュー実行（手順C）

   【claude-only モード】
   → Claude でレビュー実行（手順C）
```

## 手順A: Codex でレビュー実行

codex スキルの review コマンドを使用する。

- **コードレビュー**: `/codex:review --wait` を Skill ツールで呼び出す
- **設計・分析レビュー**: Codex に成果物を読ませてレビューさせる
  ```
  Skill(skill: "codex:review", args: "--wait")
  ```
- Codex のレビュー結果を devils-advocate のレビューフォーマットに整形して保存する
- Codex が利用不可（エラー・タイムアウト）の場合は Claude にフォールバックする

## 手順B: LM Studio でレビュー実行（economy モード）

lmstudio-mcp の chat_completion ツールを使用する。

```
mcp__lmstudio-mcp__chat_completion(
  messages: [
    {
      role: "system",
      content: "あなたはコードレビューの専門家です。以下のレビュー観点で批判的にレビューしてください: セキュリティ、パフォーマンス、保守性、アーキテクチャ。重大度（Critical/Major/Minor/Suggestion）を明記すること。"
    },
    {
      role: "user",
      content: "[レビュー対象の成果物内容]"
    }
  ]
)
```

- LM Studio のレビュー結果を devils-advocate のレビューフォーマットに整形して保存する
- LM Studio が利用不可（接続エラー等）の場合は Claude にフォールバックする

## 手順C: Claude でレビュー実行（デフォルト・フォールバック）

- 従来通り devils-advocate エージェントにレビューを委譲する
- 起動時、`.agents/TEAM.md`「チーム構成」の devils-advocate のモデル列を Agent tool の `model` パラメータに指定する（既定: fable）
- レビュー観点は `devils-advocate/CLAUDE.md` に定義されたものを使用する
