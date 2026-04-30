---
name: koumei-review
description: 成果物またはコードのレビューを実行する。レビューフェーズ（分析/設計/コード）を成果物の有無から自動判定し、devils-advocateエージェントにレビューを委譲する。
---

# Koumei Review

## Overview
タスクの進行状況に応じたレビューフェーズを自動判定し、適切なレビュー観点でdevils-advocateエージェントにレビューを実行させる。

## レビューフェーズ判定ロジック

以下の優先順位で成果物の有無を確認し、レビュー種別を自動判定する。

### 判定フロー
1. **コードレビュー**: 実装済みコードが存在する場合（`git diff` で差分あり、またはPR対象のコード変更がある）
2. **設計レビュー**: `.agents/tech-lead/deliverables/` に設計成果物が存在する場合
3. **分析レビュー**: `.agents/tech-lead/deliverables/` に設計成果物がなく、`.agents/analyst/deliverables/` に分析成果物が存在する場合

### 判定の具体的手順
```
1. git diff --name-only でコード変更の有無を確認
   → 変更あり → コードレビュー

2. ls .agents/tech-lead/deliverables/ で設計成果物の有無を確認
   → .md ファイルが存在する → 設計レビュー

3. ls .agents/analyst/deliverables/ で分析成果物の有無を確認
   → .md ファイルが存在する → 分析レビュー

4. いずれにも該当しない場合 → ユーザにレビュー対象を確認する
```

## レビューファイル命名規則

レビュー結果は `.agents/devils-advocate/reviews/` に保存する。
3種類のレビューを区別するため、以下の命名規則に従う。

| レビュー種別 | ファイル名 |
|---|---|
| 分析レビュー | `task-{番号}-analysis-review.md` |
| 設計レビュー | `task-{番号}-design-review.md` |
| コードレビュー | `task-{番号}-code-review.md` |

- `{番号}` はタスクIDまたはIssue番号を使用する（例: `task-3-analysis-review.md`）
- 同一タスクで複数フェーズのレビューが実施された場合、各フェーズごとに別ファイルとなる

## Workflow

### 0) モード判定
- `$ARGUMENTS` に `security` または `--security` が含まれる場合 → セキュリティ監査モード
- `$ARGUMENTS` に `second-opinion` または `--second-opinion` が含まれる場合 → セカンドオピニオンモード
- 両方が指定された場合 → 両モードを同時に実行
- どちらも指定されていない場合 → 通常レビュー

### 1) タスクID取得
- 引数からタスクIDを取得する。未指定の場合はユーザに確認する。

### 2) レビューフェーズ自動判定
- 上記「判定フロー」に従い、レビュー種別を決定する。
- 判定結果をユーザに表示し、確認を取る。

### 3) レビューモデル選択

TEAM.md の「レビューモデル設定」セクションを読み、使用するモデルを決定する。

#### 判定フロー

```
1. TEAM.md の review_mode を確認（未設定なら default）

2. review_mode に応じてモデルを選択:

   【default モード】
   a. codex スキルが利用可能か確認（/codex:review が存在するか）
      → 利用可能 → Codex でレビュー実行（手順3-A）
      → 利用不可 → Claude (opus) でレビュー実行（手順3-C）

   【economy モード】
   a. codex スキルが利用可能か確認
      → 利用可能 → Codex でレビュー実行（手順3-A）
   b. lmstudio-mcp が利用可能か確認（ToolSearch で mcp__lmstudio-mcp__chat_completion を検索）
      → 利用可能 → LM Studio でレビュー実行（手順3-B）
   c. いずれも不可 → Claude (opus) でレビュー実行（手順3-C）

   【claude-only モード】
   → Claude (opus) でレビュー実行（手順3-C）
```

選択されたモデルをユーザーに表示する:
「レビューモデル: {codex / lmstudio / claude (opus)}」

#### 3-A) Codex でレビュー実行

codex スキルの review コマンドを使用する。

- **コードレビュー**: `/codex:review --wait` を Skill ツールで呼び出す
- **設計・分析レビュー**: Codex に成果物を読ませてレビューさせる
  ```
  Skill(skill: "codex:review", args: "--wait")
  ```
- Codex のレビュー結果をそのまま devils-advocate のレビューフォーマットに整形して保存する
- Codex が利用不可（エラー・タイムアウト）の場合は Claude にフォールバックする

#### 3-B) LM Studio でレビュー実行（economy モード）

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

#### 3-C) Claude (opus) でレビュー実行（デフォルト・フォールバック）

- 従来通り devils-advocate エージェントにレビューを委譲する。
- レビュー観点は `devils-advocate/CLAUDE.md` に定義されたものを使用する。

### 4) レビュー結果保存
- 命名規則に従ったファイル名で `.agents/devils-advocate/reviews/` に保存する。

### セキュリティ監査モード

`/koumei-review security` または `/koumei-review --security` で実行した場合、
通常のレビュー観点に加えてOWASP Top 10 + STRIDE の完全チェックを実施する。

セキュリティ監査モードでは、レビュー結果に以下を追加で含める:
- OWASP Top 10 各項目の評価（✅/⚠️/❌/N/A）
- STRIDE 脅威分析結果
- セキュリティスコア（X/10）
- スコアが 8/10 未満の場合は VERDICT: NEEDS_REVISION を強制

レビュー結果のファイル名: `task-{番号}-security-review.md`

### セカンドオピニオンモード

`/koumei-review second-opinion` または `/koumei-review --second-opinion` で実行した場合、
通常レビューに加えてクロスモデルレビューを実施する。

#### 前提条件
- TEAM.md の「セカンドオピニオン設定」にモデルが定義されていること
- 未定義の場合は通知して通常レビューのみ実施

#### 手順
1. 通常のレビュー（手順2〜4）を実行し、Devil's Advocateレビュー結果を作成
2. TEAM.md の「セカンドオピニオン設定」セクションを確認する
   - セクション内にHTMLコメント外の通常Markdownテーブルが存在する場合 → セカンドオピニオン有効
   - テーブルがHTMLコメント（`<!-- ... -->`）内にある場合 → セカンドオピニオン未設定として扱う
   - セクション自体が存在しない場合 → セカンドオピニオン未設定として扱う
3. 設定されたモデルに対してレビュー依頼を行う
   - **Bash経由のCLI呼び出し**: TEAM.mdの「呼び出し方法」列に記載されたコマンドを Bash ツールで実行する
     - 例: `codex -q "以下のコードをレビューしてください: ..."`
     - 例: `gemini "以下の設計をレビューしてください: ..."`
   - **CLIが利用不可の場合**: ユーザーに「{モデル名}のCLIが見つかりません。セカンドオピニオンをスキップします」と通知し、通常レビュー結果のみで完了する
4. 両モデルの結果を比較し、差異分析を行う
5. 統合VERDICTを算出
6. レビュー結果を `task-{番号}-second-opinion-review.md` として保存

**注意**: セカンドオピニオンモデルが利用不可の場合、エラーとせず通常レビュー結果のみで完了する。

**注意**: セカンドオピニオンモード時、通常レビューファイル（`task-{番号}-*-review.md`）は中間成果物として生成される。最終成果物は `task-{番号}-second-opinion-review.md` であり、ユーザーはこちらを参照すること。

#### 他モードとの組み合わせ
- `security` + `second-opinion` を同時に指定した場合:
  - セキュリティ監査結果を含むレビューに対してセカンドオピニオンを実施
  - 出力ファイル: `task-{番号}-security-second-opinion-review.md`

## Notes
- レビューフォーマットは `devils-advocate/CLAUDE.md` の「レビューフォーマット」に従う。
- 各レビューには重大度（Critical / Major / Minor / Suggestion）を明記する。
