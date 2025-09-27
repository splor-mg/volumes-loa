#!/usr/bin/env bash
set -euo pipefail

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info(){ echo -e "${BLUE}[INFO]${NC} $*"; }
ok(){ echo -e "${GREEN}[OK]${NC} $*"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $*"; }
err(){ echo -e "${RED}[ERROR]${NC} $*"; }

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

CONF_DEFAULT="_dev_ploa-2025-checkpacotes_bitbucket_versoes_ultima_ploa.yml"
CONF="${1:-$CONF_DEFAULT}"

if [ ! -f "$CONF" ]; then
  err "Arquivo de configuração não encontrado: $CONF"
  exit 1
fi

if [ ! -f .env ]; then
  err ".env não encontrado na raiz: $ROOT_DIR/.env"
  exit 1
fi

info "Carregando credenciais do .env ..."
set -a
source .env
set +a

: "${BITBUCKET_AUTH_USER:=}"
: "${BITBUCKET_APP_PASSWORD:=}"
if [ -z "${BITBUCKET_AUTH_USER}" ] || [ -z "${BITBUCKET_APP_PASSWORD}" ]; then
  err "Defina BITBUCKET_AUTH_USER e BITBUCKET_APP_PASSWORD no .env"
  exit 1
fi

# Se docker não existir (provável execução dentro do container), roda direto
if ! command -v docker >/dev/null 2>&1; then
  warn "Docker CLI indisponível; assumindo execução dentro do container. Rodando instalação diretamente."
  mkdir -p logs
  Rscript _dev_ploa-2025-checkpacotes_bitbucket_install.R "$CONF" | tee -a logs/install_r_pkgs.log
  ok "Processo concluído. Veja logs em logs/install_r_pkgs.log"
  exit 0
fi

# Caminho via docker (host)
CONTAINER_NAME="volumes-loa"
if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  err "Container '$CONTAINER_NAME' não está em execução. Rode 'make docker' antes."
  exit 1
fi

# Detecta diretório do projeto no container
WORKDIR="/home/rstudio/volumes-loa"
if ! docker exec "$CONTAINER_NAME" bash -lc "[ -d '$WORKDIR' ]"; then
  ALT_DIR="/home/rstudio/projects/volumes-loa"
  if docker exec "$CONTAINER_NAME" bash -lc "[ -d '$ALT_DIR' ]"; then
    WORKDIR="$ALT_DIR"
  else
    err "Não foi possível localizar o diretório do projeto no container."
    exit 1
  fi
fi

info "Instalando pacotes conforme $CONF dentro do container $CONTAINER_NAME ..."
mkdir -p logs
docker exec \
  -e BITBUCKET_AUTH_USER="$BITBUCKET_AUTH_USER" \
  -e BITBUCKET_APP_PASSWORD="$BITBUCKET_APP_PASSWORD" \
  -e R_PKGS_CONFIG="$CONF" \
  -w "$WORKDIR" \
  "$CONTAINER_NAME" \
  bash -lc "Rscript _dev_ploa-2025-checkpacotes_bitbucket_install.R '$CONF' | tee -a logs/install_r_pkgs.log"

ok "Processo concluído. Veja logs em logs/install_r_pkgs.log"


