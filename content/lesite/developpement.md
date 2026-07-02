---
title: Lancer en local
weight: 4
---

# Lancer en local

## Prérequis

- Node.js 20 ou plus récent

Pas de base de données à installer : le contenu vient de l'API publique de LeHub (celle de production par défaut, ou d'un LeHub local si vous en faites tourner un).

## Installation

```bash
git clone <dépôt LeSite>
cd LeSite

# créer .env.local avec les variables ci-dessous

npm install
npm run dev      # http://localhost:3000
```

## Variables d'environnement

| Variable | Rôle |
|---|---|
| `NEXT_PUBLIC_SITE_URL` | URL publique du site |
| `NEXT_PUBLIC_HUB_URL` | URL du LeHub à interroger |
| `NEXT_PUBLIC_ALLOW_INDEXING` | `true` pour autoriser l'indexation par les moteurs ; toute autre valeur laisse le site en `noindex` |
| `NEXTAUTH_SECRET` | Doit être strictement identique à celui de LeHub, sinon le pont d'auth ne reconnaît personne |
| `REVALIDATE_SECRET` | Secret partagé avec LeHub pour la revalidation à la demande |
| `RESEND_API_KEY` | Envoi du formulaire de contact |
| `CONTACT_EMAIL` | Destinataire du formulaire de contact |

> [!IMPORTANT]
> Les variables `NEXT_PUBLIC_*` sont inlinées dans le JavaScript **au moment du build** (elles passent en arguments de build dans Docker). Changer une URL ou activer l'indexation demande donc de reconstruire l'image, pas seulement de redémarrer le conteneur.

## Vérifier son travail

```bash
npx tsc --noEmit     # vérification des types
npm run build        # le build est le meilleur test d'intégration :
                     # il pré-génère les pages et échoue si l'API est mal appelée
```

## Travailler sur le pont d'auth

En local, le pont d'auth ne fonctionne pas naturellement (le cookie de LeHub est posé sur `.fresquesystemique.org`). Pour développer les écrans qui en dépendent (menu compte, barre chantier), le plus simple est de tester sur l'environnement de préproduction.
