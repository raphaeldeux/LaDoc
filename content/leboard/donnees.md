---
title: Modèle de données
weight: 3
---

# Modèle de données

LeBoard n'a pas de base à lui : il travaille dans la base PostgreSQL de LeHub. Son dépôt porte son propre schéma Prisma, limité aux tables dont il a besoin, et c'est depuis ce dépôt que sont gérées les migrations des tables du plateau.

## Les tables du plateau

| Modèle | Rôle |
|---|---|
| `Board` | Un plateau : jeton d'accès (l'URL `b/[token]`), atelier LeHub associé, état (verrouillage, lots distribués), marqueur d'atelier test |
| `CardPlacement` | Chaque carte posée : position, face visible (recto/verso), lot d'origine |
| `StickyNote` | Un post-it : position, taille, couleur, texte, taille de police |
| `BoardArrow` / `Connection` | Une flèche entre deux éléments : extrémités, style, couleur |
| `AnimatorSession` | Session SSO d'un animateur venu de LeHub (jeton signé, durée courte) |

## Les tables lues chez LeHub

LeBoard lit aussi des tables administrées côté LeHub, sans les modifier :

| Modèle | Rôle |
|---|---|
| `WorkshopModel` | Le modèle de plateau choisi pour l'atelier |
| `Lot` | Les lots de cartes du modèle et leur ordre de distribution |
| `BoardLotDistribution` | Quels lots sont distribués sur quel plateau |
| `Member` | Identité de l'animateur (via le SSO) |

Le catalogue complet de ces tables est documenté dans [le modèle de données de LeHub]({{< relref "/lehub/donnees" >}}).

## Qui migre quoi

Règle de partage de la base : les migrations des tables du plateau (`Board`, `CardPlacement`, `StickyNote`, flèches) sont créées et appliquées depuis le dépôt LeBoard ; toutes les autres depuis LeHub. Les deux dépôts ne doivent jamais migrer la même table.
