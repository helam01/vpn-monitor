# 📊 Painel de Monitoramento — Netdata + Nginx

## Pré-requisitos
- Docker e Docker Compose instalados
- Porta 3055 liberada no firewall do servidor

## Como subir

### 1. Clone ou crie a estrutura de pastas
```bash
mkdir -p monitoring/netdata/health.d
mkdir -p monitoring/nginx
mkdir -p monitoring/netdata-notifications
cd monitoring
