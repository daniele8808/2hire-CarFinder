#!/usr/bin/env bash
#
# Deploy della demo 2hire · CarFinder su sviluppo.hartstudio.cloud
# ---------------------------------------------------------------
# Carica index.html, la cartella maps/ e il README sul server di
# produzione via SSH+rsync. L'aggiornamento è istantaneo (nessuna
# pipeline): appena finisce, il sito pubblico è già aggiornato.
#
#   URL pubblico:  https://sviluppo.hartstudio.cloud/2-hire-carfinder/
#
# Uso:
#   ./deploy.sh            # carica solo i file cambiati (incrementale)
#   ./deploy.sh --dry-run  # mostra cosa verrebbe caricato, senza toccare nulla
#
# Richiede l'host SSH "harttools" già configurato in ~/.ssh/config
# (HostName 188.213.167.120 = sviluppo.hartstudio.cloud).

set -euo pipefail

# --- Configurazione ---------------------------------------------------------
SSH_HOST="harttools"
REMOTE_DIR="/var/www/vhosts/hartstudio.cloud/sviluppo.hartstudio.cloud/2-hire-carfinder"
PUBLIC_URL="https://sviluppo.hartstudio.cloud/2-hire-carfinder/"

# File e cartelle da pubblicare (relativi alla root del progetto)
ASSETS=(index.html maps README.md)

# --- Preparazione -----------------------------------------------------------
cd "$(dirname "$0")"           # esegui sempre dalla root del progetto

DRY=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY="--dry-run"
  echo "▶ DRY-RUN: nessun file verrà modificato sul server."
fi

# Verifica che i file esistano
for a in "${ASSETS[@]}"; do
  if [[ ! -e "$a" ]]; then
    echo "✗ Manca '$a' nella cartella del progetto. Deploy annullato." >&2
    exit 1
  fi
done

echo "▶ Deploy verso $SSH_HOST:$REMOTE_DIR"

# --- Upload incrementale ----------------------------------------------------
# --delete    : rimuove sul server i file non più presenti in locale (mirror)
# --exclude   : esclude spazzatura macOS / git
rsync -az --delete $DRY \
  --exclude='._*' \
  --exclude='.DS_Store' \
  --exclude='.git' \
  --exclude='.github' \
  -e ssh \
  "${ASSETS[@]}" \
  "$SSH_HOST:$REMOTE_DIR/"

if [[ -n "$DRY" ]]; then
  echo "✔ Dry-run completato (niente è stato caricato)."
  exit 0
fi

# --- Verifica online --------------------------------------------------------
echo "▶ Verifica pagina pubblica…"
CODE=$(curl -s -o /dev/null -w '%{http_code}' "$PUBLIC_URL" || echo "000")
if [[ "$CODE" == "200" ]]; then
  echo "✔ Deploy completato — online: $PUBLIC_URL (HTTP $CODE)"
else
  echo "⚠ Upload eseguito, ma la pagina risponde HTTP $CODE. Controlla $PUBLIC_URL" >&2
  exit 1
fi
