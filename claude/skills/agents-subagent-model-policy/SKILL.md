---
name: agents-subagent-model-policy
description: opencode と piagentcode のサブエージェント（Agentツール・Workflow）を起動する際のモデル選択方針。調査・リサーチ系タスクや実装・コーディング系タスクをサブエージェントに委譲するとき、必ずこのスキルの方針に従ってmodelパラメータを明示指定すること。
---

# サブエージェントのモデル使い分け方針（opencode / piagentcode）

サブエージェントを起動するときは、`model` パラメータを省略せず必ず明示する。
省略すると親セッションのモデルを継承してしまい、意図しないコスト・品質になる。

> このスキルは opencode / piagentcode 向け。Claude Code 専用の `subagent-model-policy` とは別物（AGENTS.md の「Claude-Only Skillsはロード禁止」条項に従う）。表の構成を変える場合は両スキルを横並びで更新すること。

## 使い分け（暫定）

| タスクの種類 | モデル指定 |
|---|---|
| 調査・リサーチ（Web検索、コードベース探索、技術調査、ドキュメント調べ） | `deepseek-v4-flash` |
| 実装・コーディング（機械的な編集、定型的な実装、テスト追加） | `qwen/qwen3-coder-30b-a3b-instruct` |

## 判断に迷うとき

- 調査寄りの中間タスク（設計判断を含む調査など）→ 調査寄りに倒す（`deepseek-v4-flash`）
- 複雑な設計判断を伴う実装 → まずユーザーに確認する
- Workflow / agent スクリプト内のサブエージェント呼び出しにも同じ方針を適用する

## 更新注意（重要）

上記のモデル割り当ては **ローカルLLM環境が整うまでの暫定値**。
オンプレ（M4 Pro + MLX 等）でローカルモデルが運用可能になったら、
本スキルの表を日報「2026-08-01」（dailymemo）の内容に書き換えること：

- コーディング・実装 → ローカルの Qwen3-Coder-30B-A3B / Qwen3-30B-A3B 系
- 調査・クラウド判断 → DeepSeek V4 Flash / Tencent Hy3
- セキュリティ：クラウド送信前にローカルで仮名化、ZDR 有効化

書き換えの際は Claude Code 用 `subagent-model-policy` と整合を取ること。