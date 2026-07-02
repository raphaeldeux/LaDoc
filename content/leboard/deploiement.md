---
title: Déploiement
weight: 5
---

# Déploiement

## Mise en production

LeBoard se déploie par script sur le VPS, sur le même principe que les autres applications :

```bash
git pull
docker compose build
docker compose up -d
docker compose exec app npx prisma migrate deploy
```

Les migrations appliquées ici ne concernent que les tables du plateau (voir [Modèle de données]({{< relref "donnees" >}})) ; celles de LeHub sont appliquées par son propre déploiement.

## Nginx et les WebSockets

Le virtual host de `board.fresquesystemique.org` a une exigence de plus que les autres : le support WebSocket. La configuration Nginx transmet les en-têtes de montée en version du protocole :

```nginx
location / {
    proxy_pass http://<conteneur LeBoard>;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}
```

Symptôme classique d'une configuration WebSocket manquante : le plateau se charge (les pages passent) mais rien ne se synchronise entre participants (les sockets ne passent pas).

## Les images de cartes

Les images des 283 cartes (par langue) ne sont pas dans le dépôt : elles vivent dans le volume `public/cards/` sur le serveur. Un nouveau déploiement ne les touche pas ; une nouvelle langue ou une refonte graphique se déploie en copiant les fichiers.

## Environnement de préproduction

`dev.board.fresquesystemique.org` fait tourner LeBoard dans la stack Docker de développement, avec la base PostgreSQL de préproduction partagée avec `dev.hub` (voir [Infrastructure]({{< relref "/si/infrastructure" >}})). Le duo dev.hub + dev.board permet de tester le parcours complet : création d'atelier en ligne, génération du plateau, SSO animateur.
