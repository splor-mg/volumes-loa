#!/usr/bin/env bash
set -euo pipefail

# Requisitos de entrada
: "${DOCKER_IMAGE_FULL:?DOCKER_IMAGE_FULL não definido}"
USE_LOCAL_ON_FAIL="${USE_LOCAL_ON_FAIL:-}"

LOG_DIR="logs"
LOG_ERR="${LOG_DIR}/docker_pull.err"
mkdir -p "${LOG_DIR}"

echo "Baixando imagem ${DOCKER_IMAGE_FULL}..."
if docker pull "${DOCKER_IMAGE_FULL}" 2>"${LOG_ERR}"; then
  echo "Imagem baixada com sucesso."
  exit 0
fi

echo "Falha ao baixar a imagem: ${DOCKER_IMAGE_FULL}"

# Fallback: usar imagem local se solicitado e existir
if [[ "${USE_LOCAL_ON_FAIL}" == "1" ]] && docker image inspect "${DOCKER_IMAGE_FULL}" >/dev/null 2>&1; then
  echo "USE_LOCAL_ON_FAIL=1 definido e imagem local encontrada. Usando imagem local."
  exit 0
fi

# Classificação de erro e mensagens amigáveis
if grep -qiE "unauthorized|authentication required|denied" "${LOG_ERR}"; then
  echo "[Diagnóstico] Falha de autenticação/autorização no Docker Hub."
  echo "Observação: incidentes no Docker Hub às vezes retornam 401/403 mesmo para imagens públicas."
  echo "Sugestões:"
  echo " - Se a imagem for pública, experimente 'docker logout' e tente novamente."
  echo " - Se for privada, faça 'docker login' com a conta correta e tente novamente."
  echo " - Verifique a página da imagem: https://hub.docker.com/r/${DOCKER_IMAGE_FULL%:*/*}/${DOCKER_IMAGE_FULL#*/:}" || true
  echo " - Testes rápidos de conectividade:"
  echo "     curl -I https://hub.docker.com"
  echo "     curl -I https://registry-1.docker.io/v2/"
  echo " - Checar se há imagem local disponível:"
  echo "     docker image inspect ${DOCKER_IMAGE_FULL} >/dev/null 2>&1 && echo 'Imagem local disponível' || echo 'Imagem local não encontrada'"
  echo " - Para usar a imagem local como fallback, reexecute com USE_LOCAL_ON_FAIL=1."
elif grep -qiE "i/o timeout|TLS handshake|no such host|connection refused" "${LOG_ERR}"; then
  echo "[Diagnóstico] Problema de rede/indisponibilidade do Docker Hub."
  echo "Sugestões:"
  echo " - Verifique sua conexão e tente novamente mais tarde."
  echo " - Confira a página da imagem: https://hub.docker.com/r/${DOCKER_IMAGE_FULL%:*/*}/${DOCKER_IMAGE_FULL#*/:}" || true
  echo " - Testes rápidos de conectividade:"
  echo "     curl -I https://hub.docker.com"
  echo "     curl -I https://registry-1.docker.io/v2/"
  echo " - Checar se há imagem local disponível:"
  echo "     docker image inspect ${DOCKER_IMAGE_FULL} >/dev/null 2>&1 && echo 'Imagem local disponível' || echo 'Imagem local não encontrada'"
  echo " - Para usar a imagem local como fallback, reexecute com USE_LOCAL_ON_FAIL=1."
elif grep -qiE "manifest unknown|not found" "${LOG_ERR}"; then
  echo "[Diagnóstico] Tag/Imagem não encontrada no registry."
  echo "Sugestões:"
  echo " - Verifique as variáveis DOCKER_USER/DOCKER_IMAGE/DOCKER_TAG em config.mk."
elif grep -qiE "too many requests" "${LOG_ERR}"; then
  echo "[Diagnóstico] Rate limit do Docker Hub atingido."
  echo "Sugestões: aguarde alguns minutos e tente novamente, ou use a imagem local com USE_LOCAL_ON_FAIL=1."
else
  echo "[Diagnóstico] Erro ao fazer pull (detalhes em ${LOG_ERR}):"
  cat "${LOG_ERR}"
fi

exit 1


