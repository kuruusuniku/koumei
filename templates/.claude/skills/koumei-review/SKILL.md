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

### 0) セキュリティ監査モード判定
- `$ARGUMENTS` に `security` または `--security` が含まれる場合、セキュリティ監査モードで実行する
- セキュリティ監査モードでは、通常レビュー（手順2〜4）に加えて「セキュリティ監査」セクションの全チェックを実施する

### 1) タスクID取得
- 引数からタスクIDを取得する。未指定の場合はユーザに確認する。

### 2) レビューフェーズ自動判定
- 上記「判定フロー」に従い、レビュー種別を決定する。
- 判定結果をユーザに表示し、確認を取る。

### 3) レビュー実行
- devils-advocateエージェントにレビューを委譲する。
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

## Notes
- レビューフォーマットは `devils-advocate/CLAUDE.md` の「レビューフォーマット」に従う。
- 各レビューには重大度（Critical / Major / Minor / Suggestion）を明記する。
