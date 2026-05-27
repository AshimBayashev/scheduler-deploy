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
docker compose up --build -d

echo "==> Cleanup old images..."
docker image prune -f

echo ""
echo "Готово!"
echo "  UI:  https://zalupa0613.kz"
echo "  API: https://api.zalupa0613.kz"
echo ""
docker compose ps
