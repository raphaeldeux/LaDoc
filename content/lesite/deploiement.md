---
title: Déploiement
weight: 5
---

# Déploiement

## Le pipeline

Comme LeHub, LeSite se déploie automatiquement à chaque push sur `main` via GitHub Actions : connexion SSH au VPS, `git pull`, `docker compose build --no-cache`, `docker compose up -d`, reload de Nginx.

Il n'y a pas d'étape de migration : LeSite n'a pas de base de données.

## L'image et le build

Le build Next.js est en sortie `standalone`. Point d'attention principal : les variables `NEXT_PUBLIC_*` (URLs publiques, autorisation d'indexation) sont passées en **arguments de build** dans `docker-compose.yml` et figées dans le bundle. Tout changement de ces valeurs passe par un rebuild de l'image.

## Devant l'application : Nginx

Nginx (sur l'hôte) sert l'apex `fresquesystemique.org` en reverse proxy vers le conteneur, avec certificat Let's Encrypt. C'est la vitrine de l'association : toute erreur de configuration Nginx sur l'apex est immédiatement visible du public.

## Check-list après déploiement

1. La page d'accueil répond et affiche les sections interactives.
2. `/evenements` liste les ateliers publiés dans LeHub (l'API répond).
3. Un article de `/blog` s'affiche avec son image et, le cas échéant, son carrousel PDF.
4. Le mode chantier est dans l'état attendu (drapeau côté LeHub).
5. En période de pré-ouverture : vérifier que le site est toujours en `noindex` si ce n'est pas voulu.

## Mise en garde : le trio de la session partagée

Le pont d'auth entre LeHub et LeSite repose sur un cookie dont le nom et le secret doivent être identiques des deux côtés. Si l'un des deux change (montée de version NextAuth, modification de configuration), le pont se rompt sans erreur visible : les admins ne sont plus reconnus et le mode chantier bloque tout le monde. En cas de comportement étrange après un déploiement, vérifier ce point en premier.
