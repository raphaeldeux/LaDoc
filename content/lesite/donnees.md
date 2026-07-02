---
title: Modèle de données
weight: 3
---

# Modèle de données

LeSite n'a pas de base de données, et c'est un choix d'architecture : une seule source de vérité (LeHub), pas de synchronisation à maintenir, pas de contenu dupliqué qui divergerait.

## Ce que LeSite consomme

Tout le contenu dynamique vient de l'API publique de LeHub :

| Endpoint | Contenu | Utilisé par |
|---|---|---|
| `GET /api/public/articles` | Liste des actualités publiées | `/blog` |
| `GET /api/public/articles/[slug]` | Un article complet | `/blog/[slug]` |
| `GET /api/public/resources` | La médiathèque publique | `/mediatheque` |
| `GET /api/public/workshops/[slug]` | Une fiche atelier | `/evenements/[slug]` |

Les objets reçus sont volontairement pauvres en données personnelles. Par exemple, un article arrive avec deux champs calculés côté LeHub : l'avatar de l'auteur et sa tagline (ou son rôle associatif). LeSite ne connaît jamais l'e-mail, le téléphone ou le profil complet d'un membre.

## Cycle de vie d'un contenu

{{< mermaid >}}
sequenceDiagram
    participant H as LeHub (admin)
    participant S as LeSite
    participant V as Visiteur
    H->>H: publication d'un article
    H->>S: POST /api/revalidate
    S->>S: régénération des pages
    Note over S: ensuite, revalidation<br/>automatique toutes les 5 min
    V->>S: GET /blog/mon-article
    S-->>V: page servie depuis le cache
{{< /mermaid >}}

## L'état de session, seul « stockage » côté visiteur

La seule donnée que LeSite lit en dehors de l'API est le cookie de session posé par LeHub sur le domaine parent. Il sert à reconnaître un membre ou un admin connecté (menu compte, mode chantier). LeSite le déchiffre mais ne l'écrit jamais.
