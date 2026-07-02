---
title: Fonctionnalités
weight: 1
---

# Fonctionnalités

## Le plateau

- **Canvas infini** : zoom à la molette, déplacement au glisser. Chacun navigue librement sur le plateau.
- **283 cartes recto/verso** : glisser-déposer, clic pour retourner, visualiseur plein écran pour lire confortablement une carte.
- **Post-its** : notes libres, redimensionnables, avec choix de couleur et de taille de police.
- **Flèches** : outil dédié pour tracer les liens entre cartes et post-its, avec plusieurs couleurs et styles, dans les deux sens. C'est le cœur de l'exercice systémique.
- **Annuler / refaire** : historique des actions (Ctrl+Z / Ctrl+Y).

## La collaboration temps réel

Tous les participants voient les modifications des autres en direct, curseurs compris : chacun sait qui regarde quoi. La synchronisation passe par WebSocket (Socket.io), sans rechargement de page.

## Le mode animateur

L'animateur·ice dispose d'outils que les participants n'ont pas :

- **Distribution progressive des lots** : les cartes arrivent lot par lot, au rythme de l'atelier, selon le modèle de plateau défini dans LeHub.
- **Masquage par lot** : cacher un lot entier (cartes et flèches associées) pour recentrer l'attention.
- **Verrouillage du plateau** : bloquer les modifications pendant une explication.
- **Suivi de vue** : forcer la vue de tous les participants sur la sienne.

## Multi-langue et accès

- Interface et jeux de cartes en trois langues : français, anglais, espagnol.
- **Accès par lien**, sans compte : le lien du plateau est généré par LeHub et partagé par l'animateur·ice.
- **Ateliers test** : les plateaux créés depuis l'espace formation de LeHub affichent un badge « Atelier test » et expirent automatiquement après 24 heures.
