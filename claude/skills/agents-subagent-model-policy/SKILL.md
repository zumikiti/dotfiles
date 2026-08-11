---
name: agents-subagent-model-policy
description: opencode と piagentcode のサブエージェント（Agentツール・Workflow）を起動する際のモデル選択方針。opencode では用途に応じたエージェントを選択し、pi では model を明示する。
---

# サブエージェントのモデル使い分け方針（opencode / piagentcode）

ツールごとにモデルの指定方法が異なるので、以下の書き分けに従うこと。

- **opencode**: `task` ツールに `model` パラメータは無い。用途に応じて `subagent_type` を選ぶ。実モデルは `opencode/agents/*.md`（配置先 `~/.config/opencode/agents/`）の frontmatter `model:` で固定。トップレベルの `model` / `small_model`（`opencode.json`）はデフォルト・軽量タスクに効く。
- **pi agent code**: サブエージェント起動時に `model` を省略せず明示する。省略すると親セッションのモデルを継承し、意図しないコスト・品質になる。

> このスキルは opencode / piagentcode 向け。Claude Code 専用の `subagent-model-policy` とは別物（AGENTS.md の「Claude-Only Skillsはロード禁止」条項に従う）。表の構成を変える場合は両スキルを横並びで更新すること。

## 用途別ローカルモデル（oxlm / M4 Pro MLX, 48GB）

ローカルLLM（oxlm）は M4 Pro 48GB の MLX サーバ（opencode からは `oxlm/` プレフィックスで参照）。用途ごとに以下を割り当てる。

| タスク種類 | 推奨モデル (oxlm/) | 備考 |
|---|---|---|
| コーディング・実装 | `Qwen3-Coder-30B-A3B-Instruct-4bit-dwq-v2` | 主軸。精度と速度のバランス最良 |
| 計画・設計・推論 | `Qwen3-30B-A3B-Thinking-2507-MLX-4bit` | サーバ側 `enable_thinking:true` 必須 |
| 軽量・要約・分類 | `Qwen3-30B-A3B-Instruct-2507-4bit` | `small_model` 相当 |
| 外部知識・クラウド判断 | DeepSeek V4 Flash / Tencent Hy3（クラウド） | 送信前にローカルで仮名化・ZDR 有効化 |

## 使い分け

| タスクの種類 | opencode（subagent_type） | pi agent code（model） |
|---|---|---|
| 調査・リサーチ（Web検索、コードベース探索、技術調査、ドキュメント調べ） | `general` | `deepseek/deepseek-v4-flash-0731` |
| 実装・コーディング（機械的な編集、定型的な実装、テスト追加） | `coder` | `qwen/qwen3-coder-30b-a3b-instruct` |
| 計画・設計（複雑な判断、アーキテクチャ） | `plan` | `qwen3-30b-a3b-thinking`（ローカル優先） |

opencode の各エージェントに実際に割り当てられているモデルID:
- デフォルト（トップレベル `model`）→ `oxlm/Qwen3-Coder-30B-A3B-Instruct-4bit-dwq-v2`（`opencode.json`）
- `small_model` → `oxlm/Qwen3-30B-A3B-Instruct-2507-4bit`
- `plan` → `oxlm/Qwen3-30B-A3B-Thinking-2507-MLX-4bit`（`opencode.json` の `agent.plan`）
- `general` / `coder` → `opencode/agents/*.md` の `model:` を `oxlm/...` に更新すること（現状は openrouter のまま）

pi 側は `defaultProvider: openrouter` 前提のため prefix を付けない。DeepSeek は pi 側のみ日付固定版を指定している。

## 判断に迷うとき

- 調査寄りの中間タスク（設計判断を含む調査など）→ 調査側（opencode なら `general`、pi なら DeepSeek）に倒す
- 複雑な設計判断を伴う実装 → まずユーザーに確認する
- Workflow / agent スクリプト内のサブエージェント呼び出しにも同じ方針を適用する

## 更新注意（重要）

- モデル割り当ては **ローカルLLM環境（M4 Pro + MLX / oxlm）運用開始に伴い本番適用済み**（旧「暫定」注記は削除）。
- セキュリティ：クラウド送信前にローカルで仮名化、ZDR 有効化。
- 表を変更したときは `opencode/agents/*.md` の `model:` も併せて更新すること。Claude Code 用 `subagent-model-policy` と整合を取ること。
