---
id: deploiement
title: Déploiement
sidebar_position: 8
---

# Déploiement

LeSite dispose d'un CI/CD automatisé. Tout push vers la branche `main` déclenche une chaîne de déploiement via GitHub Actions.

## CI/CD GitHub Actions

Le workflow est défini dans `.github/workflows/deploy.yml`.

### Déclencheur

- Branche : `main` uniquement
- Événement : push

### Étapes du pipeline

```bash
1. Checkout code (repo local CI)
2. SSH vers VPS
3. cd /path/to/LeSite && git pull origin main
4. docker compose build --no-cache app
5. docker compose up -d --no-deps app
6. docker image prune -f (nettoie images)
7. sudo systemctl reload nginx
```

**Explication** :

- Pas de quality gates (contrairement à LeHub) : LeSite est du contenu statique public.
- Build Docker : génère l'image Next.js standalone à partir de `Dockerfile`.
- Redémarrage conteneur : force le chargement du nouveau build.
- Reload Nginx : le reverse proxy recharge sa config (important pour les changements `NEXT_PUBLIC_*` qui nécessitent un rebuild).

### Architecture déploiement

```
┌──────────────────────────────────────────────────────────────┐
│  GitHub (repo LeSite, branche main)                          │
└──────────────────────┬───────────────────────────────────────┘
                       │ push
                       ▼
        ┌──────────────────────────────┐
        │  GitHub Actions              │
        │  (runner ubuntu-latest)      │
        └──────────────────┬───────────┘
                           │ SSH
                           ▼
        ┌────────────────────────────────────────┐
        │  VPS OVH (/path/to/LeSite)        │
        │                                        │
        │  1. git pull origin main               │
        │  2. docker compose build app           │
        │  3. docker compose up -d --no-deps app│
        │  4. systemctl reload nginx             │
        └────────────────────────────────────────┘
                           │
                           ▼
        ┌────────────────────────────────────────┐
        │  Nginx (port 80/443, reverse proxy)   │
        │  ↓                                    │
        │  localhost:3002 (conteneur LeSite)   │
        └────────────────────────────────────────┘
                           │
                           ▼
        ┌────────────────────────────────────────┐
        │  Public : https://fresquesystemique.org│
        └────────────────────────────────────────┘
```

## Vérifier que le déploiement est passé

1. **Commit déployé** : push vers `main` → regarder GitHub Actions (onglet « Workflows »).
2. **Status du workflow** : ✅ all steps completed = succès ; ❌ = échec (consulter logs SSH).
3. **Logs applicatifs** (VPS) :
   ```bash
   ssh VPS
   docker compose logs app | tail -50
   ```
4. **URL à recharger** : `https://fresquesystemique.org`
   - La version new est active dès que le conteneur redémarre.
   - **Attention** : assets CSS/JS peuvent être cachés. Force-reload : **Ctrl+Shift+R** (Chrome/Firefox).

## Variantes d'env (dev, preview, prod)

LeSite supporte 3 environnements via des variables `NEXT_PUBLIC_*` :

| Env | SITE_URL | HUB_URL | ALLOW_INDEXING | Branch |
|-----|----------|---------|----------------|--------|
| **dev** | `https://auto.fresquesystemique.org` | `https://dev.hub` | `false` | (local) |
| **preview** | `https://auto.fresquesystemique.org` | `https://hub.fresquesystemique.org` | `false` | `main` |
| **prod** | `https://fresquesystemique.org` | `https://hub.fresquesystemique.org` | `true` | `main` |

Le passage **preview** → **prod** nécessite :

1. Activer `NEXT_PUBLIC_ALLOW_INDEXING=true` en variable d'env.
2. Redéployer (la variable est inlinée au build).
3. Robots moteurs verront la balise `<meta name="robots" content="index">`.

## Secrets et variables d'environnement

### Sur GitHub Secrets

- `VPS_HOST` : adresse IP/domaine du VPS
- `VPS_USER` : utilisateur SSH du VPS
- `VPS_SSH_KEY` : clé privée SSH pour authentication

### Sur le VPS (`.env` docker-compose)

```env
# .env du VPS
NEXT_PUBLIC_SITE_URL=https://fresquesystemique.org
NEXT_PUBLIC_HUB_URL=https://hub.fresquesystemique.org
NEXT_PUBLIC_ALLOW_INDEXING=true
NEXTAUTH_SECRET=<valeur partagée hub>
AUTH_SESSION_COOKIE_NAME=__Secure-fresque.session-token
REVALIDATE_SECRET=<valeur partagée hub>
CONTACT_NOTIFY_SECRET=<valeur partagée hub>
RESEND_API_KEY=<clé Resend>
CONTACT_EMAIL=contact@fresquesystemique.org
NEXT_PUBLIC_PLAUSIBLE_DOMAIN=fresquesystemique.org
NEXT_PUBLIC_PLAUSIBLE_HOST=https://plausible.fresquesystemique.org
```

Toute modification d'une variable `NEXT_PUBLIC_*` nécessite un redéploiement (rebuild Docker).

## Pièges de déploiement

### 1. Nginx doit être reload après le build

Le workflow inclut l'étape `systemctl reload nginx`. Sans elle, l'ancien conteneur reste servi. Important si :

- Ports changent.
- Certificats SSL changent (rare).

### 2. Les `NEXT_PUBLIC_*` sont cachées dans le bundle

Un changement à `NEXT_PUBLIC_HUB_URL` après le build **ne sera pas appliqué**. Seule une rebuild Docker peut le prendre en compte.

Vérification : en navigateur, ouvre la DevTools et cherche dans le bundle :

```javascript
// chunk.js (build Next.js)
window.__NEXT_PUBLIC_HUB_URL = "https://hub.fresquesystemique.org"
```

### 3. Les assets CSS/JS sont cachés en production

Après un déploiement, tu risques de voir d'anciens assets CSS/Js. C'est normal (cache navigateur ou CDN).

**Force-reload** : Ctrl+Shift+R ou Cmd+Shift+R (vide le cache local).

### 4. Mode chantier peut masquer la vraie app

Si le flag `chantier=true` est actif dans LeHub et ton administrateur n'est pas reconnu (cookie invalide), tu verras `/chantier` au lieu du vrai site.

Vérification : dans DevTools Console,
```javascript
await fetch('/api/site-mode').then(r => r.json())
// {chantier: true/false}
```

### 5. Revalidation ISR peut être lente après un déploiement

Si tu publies un nouvel article dans LeHub juste après un déploiement LeSite, la revalidation peut tarder si :

- Webhook n'arrive pas (réseau, secret mauvais).
- ISR cache prend jusqu'à 5 min.

Vérification depuis le VPS :

```bash
curl "https://fresquesystemique.org/api/revalidate?secret=REVALIDATE_SECRET"
# Si secret bon: {revalidated: true}
# Si secret mauvais: 401 Unauthorized
```

## Commandes manuelles VPS

Si tu dois redéployer manuellement sans GitHub (rare) :

```bash
ssh VPS
cd /path/to/LeSite
git pull origin main
docker compose build --no-cache app
docker compose up -d --no-deps app
sudo systemctl reload nginx
docker image prune -f
```

## Rollback

S'il faut revenir à un déploiement précédent (rare) :

```bash
ssh VPS
cd /path/to/LeSite
git log main --oneline | head -10  # Cherche le commit précédent
git reset --hard <commit-hash>
git push origin main --force-with-lease  # ⚠️ Force push (dangereux, coord avec l'équipe)
docker compose build --no-cache app
docker compose up -d --no-deps app
```

Préfère coordonner un revert propre (nouveau commit) plutôt qu'une force-push.

## Performance post-déploiement

LeSite est très rapide en production :

- Pages statiques servies par le cache ISR (hit 99% du temps).
- Pas de requête DB.
- Plausible auto-hébergé (pas de latence tiers).
- Nginx reverse proxy (très rapide).

Temps de requête typique : < 100ms (sans revalidation) à ~500ms (revalidation API LeHub).

## Monitoring et alertes

Voir le Memory du projet pour le setup de monitoring VPS et alertes Telegram (script `scripts/vps-monitor.sh` qui tourne en cron).
