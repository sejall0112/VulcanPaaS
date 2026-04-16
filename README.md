# 🌋 VulcanPaaS — AI DevOps Platform

An AI-powered internal Platform-as-a-Service (PaaS) that auto-deploys your GitHub repositories with AI code review, real-time metrics, and a live dashboard.

---

## ✅ Requirements

- **Windows 11** with [Docker Desktop](https://www.docker.com/products/docker-desktop/) (WSL2 backend, **v4.x+**)
- Docker Desktop must be **running** before you start
- PowerShell 5.1+ (built into Windows 11)
- No other process should be using **port 80**

---

## 🚀 Quick Start

### 1. Clone / Download the project

```
cd C:\Users\sejal\Downloads\VulcanPaas_AI_DevOps_Platform\VulcanPaas_AI_DevOps_Platform-main
```

### 2. Configure your environment

The `.env` file is already pre-configured for your machine. Open it to optionally add API keys:

```powershell
notepad .env
```

| Variable | Required? | Description |
|---|---|---|
| `PROJECT_ROOT` | **Yes** | Path to this folder (pre-filled) |
| `GITHUB_TOKEN` | Optional | Enables auto webhook injection |
| `GITHUB_WEBHOOK_SECRET` | Optional | Secures webhook payloads |
| `WEBHOOK_URL` | Optional | Public URL for GitHub to POST to (use ngrok for local dev) |
| `DEEPSEEK_API_KEY` | Optional | Enables AI code reviews & chatbot |

### 3. Start the platform

```powershell
.\start.ps1
```

Or manually:

```powershell
docker compose up --build -d
```

### 4. Open the dashboard

| Service | URL |
|---|---|
| 🖥️ Dashboard | http://localhost |
| 🔌 API Health | http://localhost/api/health |
| 📊 Grafana | http://localhost/grafana/ |
| 📈 Prometheus | http://localhost/prometheus/ |

---

## 🛑 Stop the platform

```powershell
docker compose down
```

To also remove all data volumes:

```powershell
docker compose down -v
```

---

## 🔧 Service Architecture

```
┌──────────┐   port 80    ┌──────────┐
│  Browser │ ────────────▶│  Nginx   │  (reverse proxy)
└──────────┘              └────┬─────┘
                               │
              ┌────────────────┼────────────────┐
              ▼                ▼                ▼
         ┌─────────┐    ┌──────────┐    ┌──────────┐
         │Frontend │    │   API    │    │ Grafana  │
         │(React)  │    │(Fastify) │    │          │
         └─────────┘    └────┬─────┘    └──────────┘
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
              ┌──────────┐    ┌──────────────┐
              │Prometheus│    │ Docker socket│
              │          │    │ (build/run)  │
              └──────────┘    └──────────────┘
```

---

## 🤖 How Auto-Deploy Works

1. Push to any GitHub repo
2. GitHub sends a webhook → `POST /webhook/github` on this API
3. VulcanPaaS:
   - Runs an **AI code review** (DeepSeek)
   - Clones/pulls the repo
   - Auto-detects project type (React/Vite/Node/Static/Dockerfile)
   - Builds a Docker image
   - Runs the container on a dynamic port
   - Adds an Nginx route at `/apps/<repo-slug>/`
4. Dashboard updates live with deployment status

> **Note:** For GitHub webhooks to reach your local machine, use [ngrok](https://ngrok.com/):
> ```powershell
> ngrok http 80
> ```
> Then set `WEBHOOK_URL=https://<your-ngrok-url>/webhook/github` in `.env` and restart.

---

## 🐛 Troubleshooting

| Problem | Fix |
|---|---|
| Port 80 already in use | Stop IIS or any local web server: `net stop w3svc` |
| Docker not running | Open Docker Desktop and wait for the whale icon to be steady |
| `docker compose` not found | Update Docker Desktop to v4+ (includes Compose V2) |
| Container stuck `starting` | Run `docker compose logs <service>` to see errors |
| Nginx 403 on first boot | Wait ~20s for all health checks to pass, then refresh |
