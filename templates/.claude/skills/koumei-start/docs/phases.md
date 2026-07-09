# Phase 1〜7 詳細手順

## Phase 1: 分析実行

### モデル委譲チェック
`.agents/TEAM.md` の「モデル委譲設定」テーブルを確認する。
`analyst` が委譲先として設定されている場合 → **Codex委譲モード**で実行する。
設定がない場合 → **通常モード**（Claudeサブエージェント）で実行する。

### 通常モード
Agent tool で `subagent_type: general-purpose` のサブエージェントを起動する。

**プロンプトに含める内容:**
- `.agents/analyst/CLAUDE.md` の役割定義
- `.claude/skills/koumei-analyze/SKILL.md` の手順セクションの内容
- 対象タスク番号と指示書のパス

### Codex委譲モード
Bash tool で `codex -q` を実行する。

**プロンプトに含める内容（通常モードと同一）:**
- `.agents/analyst/CLAUDE.md` の役割定義
- `.claude/skills/koumei-analyze/SKILL.md` の手順セクションの内容
- 対象タスク番号と指示書のパス
- 成果物・完了報告の保存先パス

**実行後:** 成果物ファイルの存在を確認する。ファイルが生成されていない場合はエラーとして報告する。

**完了後の報告:**
```
斥候隊長の報告が届いた。敵陣の情報は全て把握できたようじゃ。
次は軍監に検分を命じよう。
```

---

## Phase 2: 分析レビュー

Agent tool で devils-advocate サブエージェントを起動する。

**プロンプトに含める内容:**
- `.agents/devils-advocate/CLAUDE.md` の役割定義
- `.claude/skills/koumei-review/SKILL.md` の手順セクションの内容
- レビュー対象: 分析成果物
- レビューファイル名: `task-{番号}-analysis-review.md`

**レビュー結果のVERDICT確認:**
- **承認（APPROVED）** → Phase 3 へ進む
- **差し戻し（REVISE）** → Phase 1 を再実行（差し戻しカウンタ +1）
- **差し戻しカウンタが2を超過** → ユーザーに判断を仰ぐ

**完了後の報告:**
```
軍監の検分が終わった。分析の陣に対する評定を確認しよう。
```

---

## Phase 3: UX設計 + 技術設計（並列実行）

**1つのメッセージ内で2つの Agent tool 呼び出しを同時に行う。**

**Agent 1: ux-designer**
- `.agents/ux-designer/CLAUDE.md` の役割定義
- `.claude/skills/koumei-design-ux/SKILL.md` の手順セクションの内容
- 対象タスク番号と指示書のパス

**Agent 2: tech-lead**
- `.agents/tech-lead/CLAUDE.md` の役割定義
- `.claude/skills/koumei-design-tech/SKILL.md` の手順セクションの内容
- 対象タスク番号と指示書のパス

**両方完了後の報告:**
```
陣形師と先鋒大将の作戦立案が整った。両軍の陣を確認し、軍監の検分に移ろう。
```

---

## Phase 4: 設計レビュー

Phase 2 と同様に devils-advocate サブエージェントを起動する。

**プロンプトに含める内容:**
- `.agents/devils-advocate/CLAUDE.md` の役割定義
- `.claude/skills/koumei-review/SKILL.md` の手順セクションの内容
- レビュー対象: UX設計 + 技術設計の成果物
- レビューファイル名: `task-{番号}-design-review.md`

**レビュー結果のVERDICT確認:**
- **承認（APPROVED）** → Phase 5 へ進む
- **差し戻し（REVISE）** → Phase 3 を再実行（差し戻しカウンタ +1、フェーズ別に管理）
- **差し戻しカウンタが2を超過** → ユーザーに判断を仰ぐ

**完了後の報告:**
```
軍監の検分が終わった。作戦立案に対する評定を確認しよう。
```

---

## Phase 5: 実装

### モデル委譲チェック
`.agents/TEAM.md` の「モデル委譲設定」テーブルを確認する。
`tech-lead` が `実装（/koumei-implement）` の委譲先として設定されている場合 → **Codex委譲モード**で実行する。
設定がない場合 → **通常モード**（Claudeサブエージェント）で実行する。

### 通常モード
Agent tool で tech-lead サブエージェントを起動する。

**プロンプトに含める内容:**
- `.agents/tech-lead/CLAUDE.md` の役割定義
- `.claude/skills/koumei-implement/SKILL.md` の手順セクションの内容
- 対象タスク番号と指示書のパス
- 軽微修正（クイック）の場合: 設計書が存在しないため、タスク定義と指示書を実装の前提とすること

### Codex委譲モード
Bash tool で `codex -q` を実行する。

**プロンプトに含める内容:**
- `.agents/tech-lead/CLAUDE.md` の役割定義
- 全成果物の内容（分析・UX設計・技術設計・レビュー結果）
- `.claude/skills/koumei-implement/SKILL.md` の手順セクションの内容
- 対象タスク番号と指示書のパス
- 完了報告の保存先パス

**実行後:** ビルド確認を行い、失敗した場合はエラーとして報告する。

**開始時の報告:**
```
先鋒大将が出陣した。攻城の成否を見守ろうぞ。
```

**完了後の報告:**
```
攻城完了の報せが届いた。先鋒大将の戦果を軍監に検分させよう。
```

---

## Phase 6: コードレビュー

Phase 2 と同様に devils-advocate サブエージェントを起動する。

**プロンプトに含める内容:**
- `.agents/devils-advocate/CLAUDE.md` の役割定義
- `.claude/skills/koumei-review/SKILL.md` の手順セクションの内容
- レビュー対象: 実装コード
- レビューファイル名: `task-{番号}-code-review.md`

**レビュー結果のVERDICT確認:**
- **承認（APPROVED）** → Phase 7 へ進む
- **差し戻し（REVISE）** → Phase 5 を再実行（差し戻しカウンタ +1、フェーズ別に管理）
- **差し戻しカウンタが2を超過** → ユーザーに判断を仰ぐ

**完了後の報告:**
```
軍監の検分が終わった。実装の陣に対する評定を確認しよう。
```

---

## Phase 7: PR作成

`gh pr create` コマンドでPRを作成する。

- PRタイトル・本文はタスク定義ファイルの内容を基に孔明が作成する
- 成果物一覧・レビュー結果のサマリを本文に含める

**完了後の報告:**
```
全ての陣が整い、勝利は我が手中にある。PRを作成し、凱旋の準備を整えた。
```

**`gh pr create` 失敗時:**
```
凱旋の道が塞がれておる。{エラー内容}
```
→ リモート未設定やブランチ未プッシュ等の原因を案内して停止する。
