---
name: bitbucket-pr
description: Create and manage Bitbucket Cloud pull requests using bkt with secure defaults. Use when you need to open or update a PR, enforce the base branch `develop` (create it if missing), or manage feature branches `feature/task-id-slug` for repos listed in `.agents/TEAM.md`.
---

# Bitbucket PR

## Overview
Bitbucket CloudのPR作成を、`bkt`と安全な運用ルールで一貫化する。
`.agents/TEAM.md`の「対象プロジェクト」から対象リポジトリを選び、`develop`ベースのPRを作成する。

## 初期構築手順
1. `.agents/TEAM.md` の「対象プロジェクト」テーブルを埋める。
2. テーブルが空、または `{{PROJECT_1}}` などのプレースホルダが残っている場合はユーザに質問して埋める。
3. 各プロジェクトの `パス` はローカルのGitリポジトリにする。

## Workflow

### 1) プロジェクト選択
- `.agents/TEAM.md` から対象プロジェクトを取得する。
- 推奨: `python scripts/read_team_projects.py --path .agents/TEAM.md --pretty`
- 取得結果が空の場合は、ユーザに以下を質問して `.agents/TEAM.md` を更新する。
  - プロジェクト名
  - リポジトリのローカルパス
  - フレームワーク
  - 役割
- 複数件ある場合はユーザに選ばせる。

### 2) 安全・前提チェック
- `bkt` がインストール済みか確認する（`command -v bkt`）。
- 対象パスがGitリポジトリであることを確認する。
- `git remote -v` に `bitbucket.org` が含まれることを確認する。
- 認証トークンはOSキーチェーンに保存される前提とし、`--allow-insecure-store` はユーザ合意なしに使わない。
- `bkt` 拡張は使わない。

### 3) 基本ブランチ `develop`
- PRのベースブランチは常に `develop` とする。
- `origin/develop` が存在しない場合:
  1. デフォルトブランチを特定（`git symbolic-ref refs/remotes/origin/HEAD`、失敗時は `origin/main` または `origin/master`）。
  2. そのブランチから `develop` を作成し、`origin` にpushする。
  3. 実行内容をユーザに明示する。

### 4) featureブランチ作成
- 命名: `feature/task-id-slug`
- `task-id` はユーザから取得。
- `slug` ルール:
  - 小文字、英数字とハイフンのみ
  - 記号は除去、空白はハイフン
  - 50文字以内
- `develop` からブランチを作成する。

### 5) Commitとpush
- 変更がコミット済みであることを確認。
- コミットメッセージに自動生成マーカーや `Co-Authored-By` を含めない。
- ブランチを `origin` にpushする。

### 6) PR作成
- タイトル形式: `[<task-id>] <short summary>`
- 本文テンプレートは下記を使用。
- 必須レビュワー: **Konosuke Tamura**
- `bkt` のサブコマンド/フラグはバージョン差があるため、必ず `bkt pr --help`（または `bkt pull-request --help`）で確認してから実行する。
- レビュワー指定がCLIでできない場合は、PR作成後に編集して追加する。

### 7) 作成後チェック
- PRのベースが `develop` であることを確認。
- ソースが `feature/task-id-slug` であることを確認。
- レビュワーに **Konosuke Tamura** が設定されていることを確認。

## PR本文テンプレート
```markdown
## Summary
- 

## Changes
- 

## Test Plan
- [ ] 

## Screenshots / Logs
- 

## Risk / Notes
- 
```

## Notes
- Bitbucket CloudのリポジトリURL例:
  - `https://bitbucket.org/<workspace>/<repo>.git`
  - `git@bitbucket.org:<workspace>/<repo>.git`
- `.agents/TEAM.md` に記載がないプロジェクトは、ユーザに確認してテーブルへ追記してから作業する。
