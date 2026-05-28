#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [ ! -f .env ]; then
  echo "Файл .env не найден. Скопируй env.production.example в .env"
  exit 1
fi

# shellcheck disable=SC1091
source .env

: "${API_REPO:?API_REPO не задан в .env}"
: "${UI_REPO:?UI_REPO не задан в .env}"

if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
  echo "TELEGRAM_BOT_TOKEN: задан (${#TELEGRAM_BOT_TOKEN} символов)"
else
  echo "WARNING: TELEGRAM_BOT_TOKEN не задан в .env — Telegram будет выключен"
fi

mkdir -p repos

clone_or_pull() {
  local dir=$1
  local repo=$2
  if [ -d "repos/$dir/.git" ]; then
    echo "==> Pull $dir..."
    git -C "repos/$dir" pull --ff-only
  else
    echo "==> Clone $dir..."
    git clone "$repo" "repos/$dir"
  fi
}

clone_or_pull api "$API_REPO"
clone_or_pull ui "$UI_REPO"

echo "==> Build and start..."
docker compose up --build -d --force-recreate

echo "==> Проверка TELEGRAM_BOT_TOKEN в контейнере api..."
token_len="$(docker compose exec -T api sh -c 'printf %s "${TELEGRAM_BOT_TOKEN:-}" | wc -c' | tr -d ' \r\n')"
if [ "${token_len:-0}" -gt 10 ]; then
  echo "OK: TELEGRAM_BOT_TOKEN в контейнере (${token_len} символов)"
else
  echo "ERROR: TELEGRAM_BOT_TOKEN не попал в контейнер api — проверь /opt/zalupa0613/.env"
  exit 1
fi

echo "==> Cleanup old images..."
docker image prune -f

echo ""
echo "Готово!"
echo "  UI:  https://zalupa0613.kz"
echo "  API: https://api.zalupa0613.kz"
echo ""
docker compose ps
