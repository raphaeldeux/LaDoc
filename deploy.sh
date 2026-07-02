#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
hugo --minify --gc --printPathWarnings
rsync -a --delete public/ /var/www/ladoc/
echo "✅ Déployé → https://docs.fresquesystemique.org"
