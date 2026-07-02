---
title: Stack technique
weight: 2
---

# Stack technique

## Technologies

| Couche | Technologie |
|---|---|
| Framework | Next.js 16 (App Router, sortie standalone) |
| Langage | TypeScript, React 19 |
| Styles | Tailwind CSS 4 |
| Carte | Leaflet / React-Leaflet (agenda des événements) |
| Session | NextAuth v5, en lecture seule du cookie posé par LeHub |
| E-mails | Resend (formulaire de contact) |
| Mesure d'audience | Plausible auto-hébergé (composant `Analytics`) |
| Infra | Docker Compose, Nginx, GitHub Actions |

## Structure du code

```
app/                    # une route par page publique
  page.tsx              # accueil (sections interactives)
  evenements/           # agenda + fiche [slug]
  blog/                 # actualités + article [slug]
  mediatheque/  ateliers/  a-propos/  contact/
  confirmation/  chantier/  accessibilite/  mentions-legales/
  api/                  # contact, me, og, revalidate, site-mode
components/             # composants de pages (Header, Footer, PdfCarousel,
                        # IcebergDiagram, SystemicLoops, ChantierBar…)
lib/
  config.ts             # URLs et constantes
  events.ts             # appels à l'API publique de LeHub
  hub-auth.ts           # lecture du cookie de session LeHub (pont d'auth)
middleware.ts           # mode chantier (réécriture vers /chantier)
```

Quelques routes API à connaître :

- `api/revalidate` : appelé par LeHub à la publication d'un contenu, régénère les pages concernées (protégé par secret partagé).
- `api/me` : expose la session reconnue par le pont d'auth (menu compte).
- `api/site-mode` : état du mode chantier.
- `api/og` : génération d'images de partage.

## Rendu et cache

Les pages de contenu utilisent l'ISR de Next.js : elles sont générées statiquement, servies depuis le cache et régénérées au plus toutes les 5 minutes, ou immédiatement via `api/revalidate`. Le site reste donc rapide et disponible même si LeHub redémarre.

## SEO et partage

- Gabarit de titre commun et métadonnées Open Graph / Twitter par défaut dans `app/layout.tsx`, image de partage dédiée.
- Données structurées JSON-LD `Event` (fiches ateliers) et `Article` (actualités).
- L'indexation par les moteurs est pilotée par une variable d'environnement : le site reste en `noindex` tant qu'elle n'est pas explicitement activée. Utile pour les phases de préparation.

## Accessibilité et sobriété

Le site publie une déclaration d'accessibilité et suit une logique de sobriété (pages statiques, pas de cookies de suivi, mesure d'audience sans données personnelles).
