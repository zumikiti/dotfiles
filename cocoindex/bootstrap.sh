#!/usr/bin/env bash
# 新しい機種での初回セットアップ。
#   1) cocoindex-data volume を作り、グローバル設定(ローカル埋め込み)を seed
#   2) 埋め込みモデルの重みを取得してキャッシュ
# ネットを使うのはこの 2) のみ。以後 `docker compose up -d` は network_mode:none で
# オフライン稼働する。冪等ゆえ何度実行してもよい。
set -euo pipefail

IMG="ghcr.io/cocoindex-io/cocoindex-code@sha256:fd1f783c66440aa20c95138bb0c9b015e48d1ac7a23c111f15f290798cf05419"

echo "==> 1/2 グローバル設定を volume に seed"
docker run --rm -v cocoindex-data:/var/cocoindex "$IMG" sh -c 'mkdir -p /var/cocoindex/code && cat > /var/cocoindex/code/global_settings.yml <<YAML
embedding:
  provider: sentence-transformers
  model: Snowflake/snowflake-arctic-embed-xs
  indexing_params: {}
  query_params:
    prompt_name: query
YAML'

echo "==> 2/2 埋め込みモデルを取得(ここだけネット使用)"
docker run --rm -v cocoindex-data:/var/cocoindex \
  -e COCOINDEX_CODE_DIR=/var/cocoindex/code \
  "$IMG" ccc doctor

cat <<'MSG'

bootstrap 完了。次の手順:
  1) docker compose up -d
  2) Claude Code に MCP 登録(機種ごとに一度):
       claude mcp add cocoindex-code --scope user -- \
         sh -c 'exec docker exec -i -e COCOINDEX_CODE_HOST_CWD="$PWD" cocoindex-code ccc mcp'
MSG
