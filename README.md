# Деплой Scheduler (2 репозитория)

Инфраструктура для продакшена. Клонирует **API** и **UI** с GitHub и поднимает всё через Docker.

| Репозиторий | URL |
|-------------|-----|
| API | https://github.com/AshimBayashev/scheduler-api |
| UI | https://github.com/AshimBayashev/scheduler-ui |
| Deploy (этот) | можно запушить как `scheduler-deploy` |

---

## Структура на VPS

```
/opt/zalupa0613/          ← эта папка deploy
├── docker-compose.yml
├── Caddyfile
├── .env
├── deploy.sh
└── repos/
    ├── api/              ← git clone scheduler-api
    └── ui/               ← git clone scheduler-ui
```

---

## Быстрый старт на VPS

```bash
# 1. Docker (если ещё нет)
curl -fsSL https://get.docker.com | sh
ufw allow 22 && ufw allow 80 && ufw allow 443 && ufw --force enable

# 2. Клонировать deploy-репозиторий
cd /opt
git clone git@github.com:AshimBayashev/scheduler-deploy.git zalupa0613
# или scp папку deploy с локального ПК

cd zalupa0613

# 3. Настроить .env
cp env.production.example .env
nano .env

# 4. Запуск
chmod +x deploy.sh
./deploy.sh
```

---

## DNS на PS.kz

**Домены → Управление DNS → zalupa0613.kz**

| Тип | Имя | Значение |
|-----|-----|----------|
| A | *(пусто)* | IP VPS |
| A | `api` | IP VPS |
| A | `www` | IP VPS |

---

## .env — что заполнить

```bash
openssl rand -base64 48   # JWT_SECRET
openssl rand -base64 24   # DB_PASSWORD
```

Для **приватных** репозиториев на VPS добавь SSH-ключ:

```bash
ssh-keygen -t ed25519 -C "deploy@vps"
cat ~/.ssh/id_ed25519.pub   # добавь в GitHub → Settings → SSH keys
```

И в `.env` используй SSH-URL:

```
API_REPO=git@github.com:AshimBayashev/scheduler-api.git
UI_REPO=git@github.com:AshimBayashev/scheduler-ui.git
```

---

## Обновление

```bash
cd /opt/zalupa0613
./deploy.sh
```

Скрипт сам сделает `git pull` в `repos/api` и `repos/ui`, пересоберёт контейнеры.

---

## Локальная разработка

Работаешь в **отдельных** репозиториях:

```bash
# API
cd scheduler-api
docker compose -f docker-compose.dev.yml up -d   # postgres
npm run migration:run
npm run start:dev

# UI
cd scheduler-ui
npm run dev
```

---

## Проверка

- https://zalupa0613.kz — UI
- https://api.zalupa0613.kz — API

Логи: `docker compose logs -f`
