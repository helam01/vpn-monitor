#!/bin/bash
set -euo pipefail

# ──────────────────────────────────────────────────────────
# SH Conecta Mais — Gerador Dinâmico de Configuração HTTP Check
#
# DESCRIÇÃO:
#   Lê o arquivo 'urls.txt' e gera a configuração em formato
#   YAML aceita pelo plugin go.d/httpcheck do Netdata.
# ──────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

URLS_FILE="${APP_DIR}/urls.txt"
OUTPUT_DIR="${APP_DIR}/netdata/go.d"
OUTPUT_FILE="${OUTPUT_DIR}/httpcheck.conf"

if [ ! -f "${URLS_FILE}" ]; then
    echo "✖ ERRO: Arquivo '${URLS_FILE}' não foi encontrado."
    exit 1
fi

mkdir -p "${OUTPUT_DIR}"

cat << 'EOF' > "${OUTPUT_FILE}"
# ──────────────────────────────────────────────────────────
# CONFIGURAÇÃO DE MONITORAMENTO DE URLs (GERADO AUTOMATICAMENTE)
#
# ATENÇÃO: Não edite este arquivo diretamente!
# Para adicionar ou remover URLs, edite o arquivo 'urls.txt'
# e execute o script: ./scripts/generate-httpcheck.sh
# ──────────────────────────────────────────────────────────

jobs:
EOF

count=0

while IFS= read -r line || [ -n "$line" ]; do
    # Remove espaços em branco
    trimmed_line="$(echo "${line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    # Ignora linhas vazias e comentários
    if [[ -z "${trimmed_line}" || "${trimmed_line}" =~ ^# ]]; then
        continue
    fi

    count=$((count + 1))

    # Sanitiza o nome do job removendo protocolo e caracteres especiais
    job_name=$(echo "${trimmed_line}" | sed -E 's|^https?://||' | sed -E 's|[/:]+|_|g' | sed -E 's|[^a-zA-Z0-9_]||g')

    cat << EOF >> "${OUTPUT_FILE}"
  - name: url_${job_name}
    url: "${trimmed_line}"
    status_accepted:
      - 200
    timeout: 5

EOF
done < "${URLS_FILE}"

echo "✔ Sucesso: Configuração '${OUTPUT_FILE}' gerada com ${count} URL(s) monitorada(s)."
