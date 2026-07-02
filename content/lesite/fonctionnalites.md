---
title: Fonctionnalités
weight: 1
---

# Fonctionnalités

Le site s'adresse au grand public : personnes curieuses de la démarche, futures participantes d'ateliers, organisations intéressées. Voici ses pages, dans l'ordre où un visiteur les découvre.

## Accueil

Une page d'accueil riche et interactive qui raconte la démarche systémique : fond animé en réseau, diagramme de l'iceberg, boucles systémiques, carte des liens, parcours en U. L'objectif est de faire comprendre la fresque avant même d'y participer.

## Agenda des événements

- `/evenements` : la liste des ateliers ouverts au public, avec filtres et carte interactive (Leaflet).
- `/evenements/[slug]` : la fiche d'un atelier avec description, animateur·ices, tarifs par tiers (solidaire, classique, soutien) et inscription en ligne. Le paiement se fait sur HelloAsso, puis la personne revient sur la page de confirmation du site.
- Chaque fiche embarque des données structurées JSON-LD `Event` pour le référencement (Google, agrégateurs d'événements).

Les événements affichés sont ceux publiés dans LeHub ; les liens de partage générés dans LeHub pointent vers ces pages publiques.

## Actualités

- `/blog` : les articles publiés depuis l'admin de LeHub (catégorie, extrait, image, auteur avec avatar et tagline).
- `/blog/[slug]` : l'article complet, en Markdown riche. Un article peut embarquer un carrousel de pages PDF (défilement horizontal), généré automatiquement à partir d'un PDF téléversé dans LeHub.
- Données structurées JSON-LD `Article` et pages régénérées à la publication.

## Médiathèque

`/mediatheque` : la sélection publique de ressources documentaires (articles, livres, rapports, podcasts, vidéos) gérée dans LeHub.

## Ateliers et démarche

- `/ateliers/citoyen` : présentation de l'atelier citoyen.
- `/a-propos` : l'association, son histoire, son fonctionnement.

Une section formations (certification Qualiopi) est prévue mais pas encore construite.

## Contact

`/contact` : formulaire de contact, envoyé par e-mail à l'association (Resend).

## Pages réglementaires

Déclaration d'accessibilité (`/accessibilite`) et mentions légales (`/mentions-legales`).

## Le mode chantier

Le site a un mode « en construction », piloté depuis LeHub : quand il est actif, les visiteurs voient la page `/chantier`, tandis que les admins connectés (reconnus par le pont d'auth) naviguent normalement, avec une barre de bascule entre les deux vues. C'est le mécanisme qui a permis de construire le site en production sans l'exposer.
