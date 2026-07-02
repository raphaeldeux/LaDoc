# LaDoc

Documentation publique du SI de La Fresque Systémique (LeHub, LeSite, LeBoard), publiée sur [docs.fresquesystemique.org](https://docs.fresquesystemique.org).

## Stack

Site statique [Hugo](https://gohugo.io) avec le thème [Book](https://github.com/alex-shpak/hugo-book) (submodule git).

## Développement local

```bash
git clone --recurse-submodules https://github.com/raphaeldeux/LaDoc.git
cd LaDoc
hugo server        # http://localhost:1313
```

Prérequis : Hugo extended.

## Structure

```
content/
  _index.md        # accueil
  si/              # le SI en un coup d'œil (architecture, infrastructure)
  lehub/           # doc LeHub (6 pages)
  lesite/          # doc LeSite (6 pages)
  leboard/         # doc LeBoard (6 pages)
```

## Déploiement

Sur le serveur :

```bash
./deploy.sh        # hugo --minify puis rsync vers le répertoire servi par Nginx
```
