---
name: koumei-review
description: 成果物またはコードのレビューを実行する。レビューフェーズを自動判定し、devils-advocateエージェントにレビューを委譲する。
argument-hint: "[タスクID] [--security] [--second-opinion]"
disable-model-invocation: true
---

# Koumei Review

タスクの進行状況に応じたレビューフェーズを自動判定し、devils-advocateエージェントにレビューを実行させる。

## レビューフェーズ判定ロジック

以下の優先順位で成果物の有無を確認し、レビュー種別を自動判定する。

```
1. git diff --name-only でコード変更の有無を確認 → 変更あり → コードレビュー
2. ls .agents/tech-lead/deliverables/ → .md あり → 設計レビュー
3. ls .agents/analyst/deliverables/ → .md あり → 分析レビュー
4. いずれにも該当しない → ユーザにレビュー対象を確認する
```

## レビューファイル命名規則

| レビュー種別 | ファイル名 |
|---|---|
| 分析レビュー | `task-{番号}-analysis-review.md` |
| 設計レビュー | `task-{番号}-design-review.md` |
| コードレビュー | `task-{番号}-code-review.md` |

保存先: `.agents/devils-advocate/reviews/`

## ワークフロー

### 0) モード判定
- `$ARGUMENTS` に `security` / `--security` → セキュリティ監査モード
- `$ARGUMENTS` に `second-opinion` / `--second-opinion` → セカンドオピニオンモード
- 両方指定 → 両モード同時実行
- どちらもなし → 通常レビュー

### 1) タスクID取得
引数からタスクIDを取得。未指定の場合はユーザに確認。

### 2) レビューフェーズ自動判定
上記「判定ロジック」に従いレビュー種別を決定し、ユーザに表示。

### 3) レビューモデル選択・実行

TEAM.md の「レビューモデル設定」の `review_mode` に応じてモデルを選択する。

```
【default】  codex → claude
【economy】  codex → lmstudio → claude
【claude-only】 claude のみ
```

選択されたモデルをユーザーに表示: 「レビューモデル: {codex / lmstudio / claude ({モデル名})}」

claude で実行する場合は devils-advocate エージェントに委譲し、`.agents/TEAM.md`「チーム構成」の devils-advocate のモデル列を Agent tool の `model` パラメータに指定する（既定: fable）。

モデル別の実行手順は [docs/review-models.md](docs/review-models.md) を参照。

### 4) レビュー結果保存
命名規則に従ったファイル名で保存。

## 拡張モード

セキュリティ監査・セカンドオピニオンの詳細手順は [docs/extended-modes.md](docs/extended-modes.md) を参照。

## Notes
- レビューフォーマットは `devils-advocate/CLAUDE.md` の「レビューフォーマット」に従う
- 各レビューには重大度（Critical / Major / Minor / Suggestion）を明記する
