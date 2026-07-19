# Refonte LaDoc : Docusaurus + doc de transfert de compétences — Plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remplacer Hugo par Docusaurus dans le repo LaDoc et réécrire la documentation publique du SI de La Fresque Systémique pour qu'un successeur puisse reprendre LeHub, LeSite et LeBoard sans Raphaël, le sensible étant déporté dans un repo privé `LeRunbook`.

**Architecture:** Docusaurus (preset classic, TypeScript config) est installé à la racine du repo LaDoc existant, avec le dossier de contenu nommé `contenu/` — **pas** `docs/`, qui est déjà occupé par `docs/superpowers/`. Hugo (thème en submodule, `content/`, `layouts/`, `hugo.yaml`…) est supprimé une fois le contenu migré. Le déploiement reste identique dans son principe : build local sur le VPS puis `rsync` vers `/var/www/ladoc/` que Nginx sert déjà. Le contenu est réécrit depuis le code réel des trois repos (`/home/ubuntu/LeHub`, `/home/ubuntu/LeSite`, `/home/ubuntu/LeBoard`), pas recopié depuis Hugo.

**Tech Stack:** Docusaurus 3 (preset-classic), React 18, TypeScript, `@docusaurus/theme-mermaid`, `@easyops-cn/docusaurus-search-local` (recherche locale FR), Node 18+, npm.

## Global Constraints

- **Langue : français uniquement.** Pas d'i18n, pas de versioning Docusaurus (YAGNI).
- **Dossier de contenu Docusaurus = `contenu/`.** `docs/` est réservé à `docs/superpowers/` (specs et plans) et ne doit jamais être servi par le site.
- **Rien de sensible dans LaDoc** : aucune IP, aucun port, aucun chemin serveur absolu (`/var/www/...`, `/opt/...`, `/home/ubuntu/...`), aucun nom de fichier `.env` avec sa localisation, aucun identifiant, aucun ID de chat Telegram, aucun nom de bucket. Tout cela va dans LeRunbook. Les chemins **dans les repos applicatifs** (`app/api/...`, `lib/...`, `prisma/schema.prisma`) sont publics et attendus.
- **Contenu écrit depuis le code réel** : chaque affirmation sur un modèle de données, une route ou un flux doit être vérifiée dans le repo concerné avant d'être écrite. Pas de copier-coller du contenu Hugo.
- **Style rédactionnel** : pas de tics d'écriture IA — pas de tournure « ce n'est pas X, c'est Y », pas de tiret cadratin.
- **URL de production** : `https://docs.fresquesystemique.org/`, servie à la racine (`baseUrl: '/'`).
- **Repo public LaDoc** : `https://github.com/raphaeldeux/LaDoc`. Repo privé à créer : `LeRunbook` (même compte, **privé**).
- Commit après chaque tâche. Pas de push en prod avant la tâche 8.

---

### Task 1 : Socle Docusaurus, retrait de Hugo, pipeline de déploiement

Cette tâche remplace la plomberie et rien d'autre : à la fin, `npm run build` produit un site vide-mais-valide et `deploy.sh` sait le publier. Le contenu vient dans les tâches suivantes.

**Files:**
- Create: `/home/ubuntu/LaDoc/package.json`
- Create: `/home/ubuntu/LaDoc/docusaurus.config.ts`
- Create: `/home/ubuntu/LaDoc/sidebars.ts`
- Create: `/home/ubuntu/LaDoc/tsconfig.json`
- Create: `/home/ubuntu/LaDoc/src/css/custom.css`
- Create: `/home/ubuntu/LaDoc/contenu/accueil.md` (page provisoire, réécrite en tâche 2)
- Modify: `/home/ubuntu/LaDoc/deploy.sh`
- Modify: `/home/ubuntu/LaDoc/.gitignore`
- Modify: `/home/ubuntu/LaDoc/README.md`
- Delete (en fin de tâche) : `hugo.yaml`, `.hugo_build.lock`, `.gitmodules`, `archetypes/`, `assets/`, `data/`, `i18n/`, `layouts/`, `themes/`, `resources/`, `static/`
- Conserve temporairement : `content/` (source de migration, supprimé en tâche 6)

- [ ] **Step 1 : Vérifier le prérequis Node**

```bash
node --version   # doit être >= 18
npm --version
```

Si Node < 18, arrêter et le signaler à Raphaël : Docusaurus 3 ne démarre pas en dessous.

- [ ] **Step 2 : Initialiser Docusaurus dans un dossier temporaire**

Le générateur refuse d'écrire dans un dossier non vide, donc on génère à côté puis on rapatrie.

```bash
cd /tmp/claude-1000/-home-ubuntu/*/scratchpad
npx --yes create-docusaurus@latest ladoc-scaffold classic --typescript
```

- [ ] **Step 3 : Rapatrier le squelette dans LaDoc**

```bash
cd /tmp/claude-1000/-home-ubuntu/*/scratchpad/ladoc-scaffold
cp package.json tsconfig.json docusaurus.config.ts sidebars.ts /home/ubuntu/LaDoc/
mkdir -p /home/ubuntu/LaDoc/src/css
cp src/css/custom.css /home/ubuntu/LaDoc/src/css/custom.css
```

Ne **pas** copier `docs/`, `blog/`, `src/pages/`, `src/components/`, `static/` du scaffold : le contenu d'exemple n'est pas voulu, et `docs/` écraserait `docs/superpowers/`.

- [ ] **Step 4 : Installer les dépendances, dont Mermaid et la recherche locale**

```bash
cd /home/ubuntu/LaDoc
npm install
npm install @docusaurus/theme-mermaid @easyops-cn/docusaurus-search-local
```

- [ ] **Step 5 : Écrire la configuration**

Remplacer intégralement `/home/ubuntu/LaDoc/docusaurus.config.ts` par :

```ts
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import {themes as prismThemes} from 'prism-react-renderer';

const config: Config = {
  title: 'LaDoc',
  tagline: 'Documentation du système d’information de La Fresque Systémique',
  favicon: 'img/favicon.ico',

  url: 'https://docs.fresquesystemique.org',
  baseUrl: '/',

  organizationName: 'raphaeldeux',
  projectName: 'LaDoc',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'throw',

  i18n: {
    defaultLocale: 'fr',
    locales: ['fr'],
  },

  markdown: {
    mermaid: true,
  },
  themes: [
    '@docusaurus/theme-mermaid',
    [
      require.resolve('@easyops-cn/docusaurus-search-local'),
      {
        hashed: true,
        language: ['fr'],
        indexBlog: false,
        docsRouteBasePath: '/',
      },
    ],
  ],

  presets: [
    [
      'classic',
      {
        docs: {
          path: 'contenu',
          routeBasePath: '/',
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/raphaeldeux/LaDoc/tree/master/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: {
      defaultMode: 'light',
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'LaDoc',
      items: [
        {type: 'docSidebar', sidebarId: 'principal', position: 'left', label: 'Documentation'},
        {href: 'https://github.com/fresquesystemique', label: 'GitHub', position: 'right'},
      ],
    },
    footer: {
      style: 'dark',
      copyright: `La Fresque Systémique — documentation publique du SI. Dernière mise à jour : ${new Date().getFullYear()}.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'json', 'sql', 'prisma'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
```

Note : `routeBasePath: '/'` sert la doc à la racine du domaine (pas de `/docs/`), ce qui préserve la forme actuelle des URLs Hugo.

- [ ] **Step 6 : Écrire la sidebar**

Remplacer intégralement `/home/ubuntu/LaDoc/sidebars.ts` par la structure cible complète. Les documents référencés sont créés au fil des tâches 2 à 6 ; le build échouera tant qu'ils manquent, ce qui est le comportement voulu (il sert de checklist).

```ts
import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  principal: [
    'accueil',
    {
      type: 'category',
      label: 'LeHub',
      link: {type: 'doc', id: 'lehub/index'},
      items: [
        'lehub/fonctionnalites',
        'lehub/architecture',
        'lehub/donnees',
        'lehub/flux',
        'lehub/integrations',
        'lehub/developpement',
        'lehub/deploiement',
      ],
    },
    {
      type: 'category',
      label: 'LeSite',
      link: {type: 'doc', id: 'lesite/index'},
      items: [
        'lesite/fonctionnalites',
        'lesite/architecture',
        'lesite/donnees',
        'lesite/flux',
        'lesite/integrations',
        'lesite/developpement',
        'lesite/deploiement',
      ],
    },
    {
      type: 'category',
      label: 'LeBoard',
      link: {type: 'doc', id: 'leboard/index'},
      items: [
        'leboard/fonctionnalites',
        'leboard/architecture',
        'leboard/donnees',
        'leboard/flux',
        'leboard/integrations',
        'leboard/developpement',
        'leboard/deploiement',
      ],
    },
    {
      type: 'category',
      label: 'Le SI transverse',
      link: {type: 'doc', id: 'si/index'},
      items: [
        'si/infrastructure',
        'si/environnements',
        'si/monitoring',
        'si/sauvegardes',
        'si/pieges',
      ],
    },
  ],
};

export default sidebars;
```

- [ ] **Step 7 : Créer une page d'accueil provisoire**

Créer `/home/ubuntu/LaDoc/contenu/accueil.md` :

```markdown
---
id: accueil
title: Vue d'ensemble du SI
slug: /
sidebar_position: 1
---

# Vue d'ensemble du SI

Page en cours de rédaction (tâche 2 du plan).
```

- [ ] **Step 8 : Réduire temporairement la sidebar pour valider la plomberie**

Pour vérifier que le socle fonctionne avant d'avoir le contenu, commenter dans `sidebars.ts` les quatre catégories (LeHub, LeSite, LeBoard, Le SI transverse) en ne laissant que `'accueil'` dans `principal`. Elles seront rétablies au fur et à mesure — chaque tâche de contenu réactive sa catégorie.

- [ ] **Step 9 : Vérifier que le build passe**

```bash
cd /home/ubuntu/LaDoc && npm run build
```

Attendu : `[SUCCESS] Generated static files in "build".` Aucun avertissement de lien cassé (ils sont en `throw`).

- [ ] **Step 10 : Vérifier le rendu en local**

```bash
cd /home/ubuntu/LaDoc && npm run serve -- --port 3010 --no-open &
sleep 5
curl -sS http://localhost:3010/ | head -20
```

Attendu : du HTML contenant `Vue d'ensemble du SI`. Puis arrêter le serveur (`kill %1`).

- [ ] **Step 11 : Adapter le script de déploiement**

Remplacer `/home/ubuntu/LaDoc/deploy.sh` par :

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
npm ci
npm run build
rsync -a --delete build/ /var/www/ladoc/
echo "✅ Déployé → https://docs.fresquesystemique.org"
```

Docusaurus écrit dans `build/` là où Hugo écrivait dans `public/` : c'est la seule différence côté rsync, la destination et Nginx ne changent pas.

- [ ] **Step 12 : Mettre à jour `.gitignore`**

Remplacer le contenu de `/home/ubuntu/LaDoc/.gitignore` par :

```
node_modules/
build/
.docusaurus/
.cache-loader/
```

- [ ] **Step 13 : Retirer Hugo**

```bash
cd /home/ubuntu/LaDoc
git submodule deinit -f themes/hugo-book
git rm -r --cached themes/hugo-book
rm -rf themes .git/modules/themes
git rm -f .gitmodules hugo.yaml
rm -f .hugo_build.lock
git rm -r -f --ignore-unmatch archetypes assets data i18n layouts static
rm -rf resources public
```

`content/` est volontairement conservé à ce stade : il sert de source de comparaison pendant la migration. Il est supprimé en tâche 6.

- [ ] **Step 14 : Mettre à jour le README**

Remplacer les sections « Stack », « Développement local », « Structure » et « Déploiement » de `/home/ubuntu/LaDoc/README.md` par :

```markdown
## Stack

Site statique [Docusaurus 3](https://docusaurus.io) (preset classic, TypeScript), recherche locale et schémas Mermaid.

## Développement local

```bash
git clone https://github.com/raphaeldeux/LaDoc.git
cd LaDoc
npm install
npm start          # http://localhost:3000
```

Prérequis : Node 18+.

## Structure

```
contenu/           # les pages de la documentation (dossier docs de Docusaurus)
  accueil.md       # vue d'ensemble du SI
  lehub/           # doc LeHub (7 pages)
  lesite/          # doc LeSite (7 pages)
  leboard/         # doc LeBoard (7 pages)
  si/              # le SI transverse
docs/superpowers/  # specs et plans de chantier (non publiés)
sidebars.ts        # arborescence du menu latéral
```

Le contenu vit dans `contenu/` et non dans `docs/`, ce dernier étant déjà occupé par les specs de chantier.

## Contenu sensible

Ce site est public. Les accès, IP, ports, chemins serveur et procédures opérationnelles vivent dans le repo privé `LeRunbook`.

## Déploiement

Sur le serveur :

```bash
./deploy.sh        # npm ci && npm run build puis rsync vers le répertoire servi par Nginx
```
```

- [ ] **Step 15 : Vérifier que le build passe toujours après le retrait de Hugo**

```bash
cd /home/ubuntu/LaDoc && rm -rf build .docusaurus && npm run build
```

Attendu : `[SUCCESS] Generated static files in "build".`

- [ ] **Step 16 : Commit**

```bash
cd /home/ubuntu/LaDoc
git add -A
git commit -m "feat(ladoc): remplace Hugo par Docusaurus (socle + deploy)"
```

---

### Task 2 : Page d'accueil et schéma global du SI

**Files:**
- Modify: `/home/ubuntu/LaDoc/contenu/accueil.md`

**Interfaces:**
- Consumes: le socle Docusaurus de la tâche 1 (`markdown.mermaid: true`, `slug: /`).
- Produces: la page racine `/`, cible des liens `[LeHub](/lehub/)`, `[LeSite](/lesite/)`, `[LeBoard](/leboard/)` créés en tâches 3 à 5. Ces liens ne doivent être écrits qu'à la tâche 6 pour ne pas casser le build en `onBrokenLinks: 'throw'` — dans cette tâche, laisser les trois noms en texte simple et ajouter un commentaire `<!-- liens ajoutés en tâche 6 -->`.

- [ ] **Step 1 : Relire l'ancienne page d'accueil et l'architecture Hugo**

```bash
cd /home/ubuntu/LaDoc && cat content/_index.md content/si/architecture.md
```

Objectif : récupérer les faits justes, pas la formulation. Tout ce qui est repris doit être revérifié dans le code.

- [ ] **Step 2 : Vérifier les faits d'architecture dans les trois repos**

```bash
cd /home/ubuntu
head -40 LeHub/README.md LeSite/README.md LeBoard/README.md
cat LeHub/package.json LeSite/package.json LeBoard/package.json | grep -E '"(name|next|react|@prisma/client)"'
```

Noter pour chaque app : son rôle, sa stack, sa base de données, ses dépendances externes.

- [ ] **Step 3 : Écrire la page d'accueil**

Remplacer intégralement `/home/ubuntu/LaDoc/contenu/accueil.md`. Structure imposée :

```markdown
---
id: accueil
title: Vue d'ensemble du SI
slug: /
sidebar_position: 1
---

# Le SI de La Fresque Systémique

<!-- 1. Un paragraphe : à quoi sert ce SI, pour qui. -->

## À qui s'adresse cette documentation

<!-- 2. Écrire explicitement : elle vise le transfert de compétences vers un
     développeur qui reprend le SI. Dire ce qui est ici (le public : architecture,
     données, flux, pièges) et ce qui n'y est pas (les accès et procédures
     serveur, dans le repo privé LeRunbook). -->

## Les trois applications

<!-- 3. Un tableau : Application | Rôle | Adresse publique | Stack. -->

## Qui parle à qui

```mermaid
graph TB
  %% 4. Schéma global : les 3 apps, la base Postgres, HelloAsso,
  %% l'API Adresse (BAN), Telegram, Backblaze B2, Plausible, le VPS.
  %% Une flèche par échange réel, libellée (ex. "webhook paiement").
  %% Ne pas inventer : chaque flèche doit correspondre à du code vérifié.
```

## Par où commencer

<!-- 5. Trois parcours de lecture selon le besoin : reprendre le SI de zéro /
     corriger un bug sur une app / opérer la prod (renvoi vers LeRunbook). -->
```

Chaque commentaire `<!-- n -->` est à remplacer par le contenu rédigé ; aucun commentaire ne doit subsister dans le fichier final.

- [ ] **Step 4 : Vérifier le build et le rendu du schéma**

```bash
cd /home/ubuntu/LaDoc && npm run build && npm run serve -- --port 3010 --no-open &
sleep 5
curl -sS http://localhost:3010/ | grep -c mermaid
kill %1
```

Attendu : build en `SUCCESS`, et le `grep -c` retourne au moins 1 (le bloc Mermaid est bien présent dans le HTML).

- [ ] **Step 5 : Commit**

```bash
cd /home/ubuntu/LaDoc
git add contenu/accueil.md
git commit -m "docs(accueil): vue d'ensemble du SI et schéma global"
```

---

### Task 3 : Documentation LeHub (8 fichiers)

LeHub est l'application la plus riche (530 lignes de `schema.prisma`, HelloAsso, crons, badges). C'est la tâche de contenu la plus lourde ; la faire en premier fixe le gabarit des deux autres.

**Files:**
- Create: `/home/ubuntu/LaDoc/contenu/lehub/index.md`
- Create: `/home/ubuntu/LaDoc/contenu/lehub/fonctionnalites.md`
- Create: `/home/ubuntu/LaDoc/contenu/lehub/architecture.md`
- Create: `/home/ubuntu/LaDoc/contenu/lehub/donnees.md`
- Create: `/home/ubuntu/LaDoc/contenu/lehub/flux.md`
- Create: `/home/ubuntu/LaDoc/contenu/lehub/integrations.md`
- Create: `/home/ubuntu/LaDoc/contenu/lehub/developpement.md`
- Create: `/home/ubuntu/LaDoc/contenu/lehub/deploiement.md`
- Modify: `/home/ubuntu/LaDoc/sidebars.ts` (réactiver la catégorie LeHub)

**Interfaces:**
- Consumes: la sidebar de la tâche 1, dont les `id` attendus sont exactement `lehub/index`, `lehub/fonctionnalites`, `lehub/architecture`, `lehub/donnees`, `lehub/flux`, `lehub/integrations`, `lehub/developpement`, `lehub/deploiement`.
- Produces: le **gabarit des 7 pages** réutilisé tel quel pour LeSite (tâche 4) et LeBoard (tâche 5). Les titres de sections définis ici font foi pour les trois outils.

- [ ] **Step 1 : Relever la matière dans le repo LeHub**

```bash
cd /home/ubuntu/LeHub
cat README.md CLAUDE.md
cat prisma/schema.prisma
ls app app/api components lib scripts
cat .github/workflows/deploy.yml
cat .env.example
```

`.env.example` sert à lister les **noms** des variables d'environnement ; ne jamais reporter une valeur, même d'exemple.

- [ ] **Step 2 : Relever les flux critiques**

```bash
cd /home/ubuntu/LeHub
ls -R app/api | head -60
grep -rl "helloasso" --include=*.ts --include=*.tsx -i . | grep -v node_modules
ls scripts
```

Identifier au minimum : inscription + paiement + webhook HelloAsso, annulation/remboursement, attribution des badges, les crons (rappels, réconciliation des UsageReport), la modération.

- [ ] **Step 3 : Écrire `index.md`**

```markdown
---
id: index
title: LeHub
sidebar_position: 1
---

# LeHub

<!-- Le rôle de LeHub en 2-3 paragraphes : intranet des animateurs et formateurs,
     gestion des ateliers, inscriptions, paiements, formations, badges.
     Puis un tableau des 7 pages de la section avec une ligne de description
     chacune, pour orienter le lecteur. -->
```

- [ ] **Step 4 : Écrire `fonctionnalites.md`**

Organisation **par parcours utilisateur**, pas par écran. Sections imposées :

```markdown
---
id: fonctionnalites
title: Présentation & fonctionnalités
sidebar_position: 2
---

# Présentation & fonctionnalités

## Les rôles et ce qu'ils peuvent faire
<!-- Tableau : rôle | périmètre. Attention : les administrateurs ont
     isAdmin=true mais role='formateur' — le dire explicitement, c'est un
     piège de lecture du code. Les adhérents n'ont pas accès au Hub :
     accès minimum = animateur. -->

## Parcours : un animateur crée et anime un atelier
## Parcours : un participant s'inscrit et paie
## Parcours : un formateur suit une formation et ses habilitations
## Parcours : un administrateur pilote et modère
```

Chaque parcours est raconté pas à pas, en nommant les pages traversées et leur route (`app/(app)/...`).

- [ ] **Step 5 : Écrire `architecture.md`**

Sections imposées :

```markdown
---
id: architecture
title: Architecture technique
sidebar_position: 3
---

# Architecture technique

## Stack
<!-- Versions réelles lues dans package.json. -->

## Où vit quoi
<!-- Tableau : Chemin | Responsabilité. Une ligne par dossier de premier
     niveau ET par sous-dossier significatif de app/, components/, lib/,
     scripts/. C'est le cœur de la page : un successeur doit pouvoir
     trouver un fichier sans grep. -->

## Conventions de routage
<!-- Les groupes de routes Next.js utilisés et pourquoi
     (ex. app/(fullscreen)/ pour le formulaire de satisfaction). -->

## Conventions UI
<!-- Tokens shadcn uniquement, statuts centralisés dans lib/workshop-status.ts. -->

## Authentification et autorisation
<!-- Session, cookie, middleware, la règle isAdmin, hasProHabilitation(). -->
```

- [ ] **Step 6 : Générer la page `donnees.md` depuis le schéma réel**

La page doit couvrir **tous** les modèles de `prisma/schema.prisma`. Procédure :

```bash
cd /home/ubuntu/LeHub && grep -n "^model\|^enum" prisma/schema.prisma
```

Pour chaque modèle, écrire une sous-section :

```markdown
### NomDuModele

<!-- Une phrase : son rôle métier. -->

| Champ | Type | Rôle |
| --- | --- | --- |

**Relations** : <!-- liste des relations et leur sens -->
```

Terminer la page par un diagramme Mermaid `erDiagram` des relations principales (ne pas y mettre les 40 modèles : les entités centrales et leurs liens).

- [ ] **Step 7 : Écrire `flux.md`**

Un flux = une section, avec un diagramme Mermaid `sequenceDiagram` puis le pas-à-pas commenté renvoyant aux fichiers réels. Flux imposés :

```markdown
## Inscription, paiement et webhook HelloAsso
## Annulation et remboursement
## Attribution des badges
## Les tâches planifiées (crons)
## Modération des contenus
```

Pour chaque flux, indiquer explicitement **ce qui se passe si l'étape échoue** (webhook perdu, e-mail non parti) et le mécanisme de rattrapage s'il existe.

- [ ] **Step 8 : Écrire `integrations.md`**

Une section par intégration : HelloAsso, API Adresse (BAN), Telegram, Backblaze B2, Plausible. Pour chacune : ce qu'elle apporte, comment elle est appelée (fichier), les **noms** des variables d'environnement nécessaires (jamais de valeurs), le comportement en cas d'indisponibilité.

Ajouter un encadré sur le piège CSP :

```markdown
:::warning Piège : la CSP n'est active qu'en production
Un domaine externe absent de `connect-src` ne provoque aucune erreur avec
`npm run dev`. Toute nouvelle intégration doit être testée avec un build de
production local avant déploiement.
:::
```

- [ ] **Step 9 : Écrire `developpement.md`**

Sections : prérequis, installation, variables d'environnement (noms et rôles seulement), lancement, tests, environnement `dev.hub` (en décrivant le principe — stack de dev partagée, base commune avec `dev.board` — sans donner d'adresse d'accès ni de port), et une section « Pièges de développement » propre à LeHub.

- [ ] **Step 10 : Écrire `deploiement.md`**

Décrire le CI/CD réel lu dans `.github/workflows/deploy.yml` : déclencheur, étapes, ce qui est construit, comment vérifier qu'un déploiement est passé (commit déployé, logs applicatifs, page à recharger). Ajouter :

```markdown
:::danger Ne pas déployer à la main
LeHub dispose d'un CI/CD qui redéploie automatiquement sur push. Lancer en
plus un déploiement manuel provoque une collision.
:::
```

Les commandes serveur elles-mêmes appartiennent à LeRunbook : y renvoyer sans les reproduire.

- [ ] **Step 11 : Réactiver la catégorie LeHub dans la sidebar**

Décommenter le bloc `label: 'LeHub'` dans `/home/ubuntu/LaDoc/sidebars.ts` (écrit en tâche 1, step 6).

- [ ] **Step 12 : Vérifier le build**

```bash
cd /home/ubuntu/LaDoc && npm run build
```

Attendu : `SUCCESS`. Un échec `Docs markdown link couldn't be resolved` signale un lien interne vers une page pas encore écrite — le corriger plutôt que de relâcher `onBrokenLinks`.

- [ ] **Step 13 : Vérifier l'absence de contenu sensible**

```bash
cd /home/ubuntu/LaDoc && grep -rnE '([0-9]{1,3}\.){3}[0-9]{1,3}|/var/www|/home/ubuntu|:(3[0-9]{3}|5[0-9]{3})|\.env\.production|chat_id|-?50169' contenu/lehub/
```

Attendu : aucune correspondance. Toute occurrence doit être retirée ou déplacée vers LeRunbook.

- [ ] **Step 14 : Commit**

```bash
cd /home/ubuntu/LaDoc
git add contenu/lehub sidebars.ts
git commit -m "docs(lehub): 7 pages de transfert de compétences"
```

---

### Task 4 : Documentation LeSite (8 fichiers)

**Files:**
- Create: `/home/ubuntu/LaDoc/contenu/lesite/{index,fonctionnalites,architecture,donnees,flux,integrations,developpement,deploiement}.md`
- Modify: `/home/ubuntu/LaDoc/sidebars.ts` (réactiver la catégorie LeSite)

**Interfaces:**
- Consumes: le gabarit des 7 pages fixé en tâche 3 — mêmes titres de sections, mêmes `sidebar_position`, mêmes conventions d'encadrés.
- Produces: rien de nouveau pour les tâches suivantes, hormis les cibles de liens `/lesite/...`.

- [ ] **Step 1 : Relever la matière dans le repo LeSite**

```bash
cd /home/ubuntu/LeSite
cat README.md middleware.ts next.config.js .env.example
ls -R app components lib | head -80
cat .github/workflows/deploy.yml
ls tests
```

- [ ] **Step 2 : Écrire les 8 pages sur le gabarit de la tâche 3**

Adapter au périmètre réel de LeSite. Points qui lui sont propres et qui doivent apparaître :

- LeSite est **le seul site public** (apex) ; LeHub est intranet.
- Vitrine publique des événements : `/evenements/[slug]`, alimentée par les données de LeHub.
- La section Formations (Qualiopi) : `/formations` et ses sous-pages.
- Le carrousel PDF des articles (upload PDF → conversion poppler puis webp).
- Le mode chantier et le pont d'authentification avec LeHub.
- Plausible auto-hébergé pour l'analytics (GlitchTip/Sentry a été retiré, ne pas le mentionner comme actif).
- LeSite n'a pas de `prisma/schema.prisma` propre : la page `donnees.md` doit expliquer **d'où viennent les données** (base partagée, modèles consommés, ce que LeSite lit et n'écrit pas) plutôt que redécrire des modèles.

- [ ] **Step 3 : Documenter le piège du cookie de session dans `architecture.md`**

```markdown
:::warning Le nom du cookie de session est dupliqué
Le nom du cookie de session est codé en dur à trois endroits, dont
`middleware.ts` de LeSite. Les trois doivent rester synchronisés : une
divergence casse silencieusement le contournement administrateur du mode
chantier.
:::
```

- [ ] **Step 4 : Réactiver la catégorie LeSite dans la sidebar**

- [ ] **Step 5 : Vérifier le build**

```bash
cd /home/ubuntu/LaDoc && npm run build
```

Attendu : `SUCCESS`.

- [ ] **Step 6 : Vérifier l'absence de contenu sensible**

```bash
cd /home/ubuntu/LaDoc && grep -rnE '([0-9]{1,3}\.){3}[0-9]{1,3}|/var/www|/home/ubuntu|:(3[0-9]{3}|5[0-9]{3})|\.env\.production|chat_id' contenu/lesite/
```

Attendu : aucune correspondance.

- [ ] **Step 7 : Commit**

```bash
cd /home/ubuntu/LaDoc
git add contenu/lesite sidebars.ts
git commit -m "docs(lesite): 7 pages de transfert de compétences"
```

---

### Task 5 : Documentation LeBoard (8 fichiers)

**Files:**
- Create: `/home/ubuntu/LaDoc/contenu/leboard/{index,fonctionnalites,architecture,donnees,flux,integrations,developpement,deploiement}.md`
- Modify: `/home/ubuntu/LaDoc/sidebars.ts` (réactiver la catégorie LeBoard)

**Interfaces:**
- Consumes: le gabarit des 7 pages fixé en tâche 3.
- Produces: les cibles de liens `/leboard/...`.

- [ ] **Step 1 : Relever la matière dans le repo LeBoard**

```bash
cd /home/ubuntu/LeBoard
cat README.md prisma/schema.prisma .env.example
ls -R src server | head -80
cat .github/workflows/deploy.yml
```

- [ ] **Step 2 : Écrire les 8 pages sur le gabarit de la tâche 3**

Points propres à LeBoard à faire figurer :

- Le plateau collaboratif : rendu Konva, temps réel côté `server/`.
- Le modèle cartes / lots / distributions (`BoardLotDistribution`) et le piège de suppression en cascade.
- Les étapes et matrices d'atelier.
- L'éditeur de cartes administrateur (`/admin/cards/[id]`) avec sauvegarde automatique.

- [ ] **Step 3 : Documenter les deux pièges de rendu dans `architecture.md`**

```markdown
:::warning Cartes floues au zoom
Le flou au zoom vient du cache bitmap de Konva, pas de la résolution des
images sources. Invalider le cache au changement d'échelle plutôt que
d'augmenter la taille des visuels.
:::

:::warning Zoom haché
Un pas de zoom fixe par événement, avec un rendu complet à chaque cran,
donne un zoom saccadé. Le zoom doit être continu et le rendu découplé des
crans.
:::
```

- [ ] **Step 4 : Réactiver la catégorie LeBoard dans la sidebar**

- [ ] **Step 5 : Vérifier le build**

```bash
cd /home/ubuntu/LaDoc && npm run build
```

Attendu : `SUCCESS`.

- [ ] **Step 6 : Vérifier l'absence de contenu sensible**

```bash
cd /home/ubuntu/LaDoc && grep -rnE '([0-9]{1,3}\.){3}[0-9]{1,3}|/var/www|/home/ubuntu|:(3[0-9]{3}|5[0-9]{3})|\.env\.production|chat_id' contenu/leboard/
```

Attendu : aucune correspondance.

- [ ] **Step 7 : Commit**

```bash
cd /home/ubuntu/LaDoc
git add contenu/leboard sidebars.ts
git commit -m "docs(leboard): 7 pages de transfert de compétences"
```

---

### Task 6 : Section SI transverse, liens de l'accueil, retrait de `content/`

**Files:**
- Create: `/home/ubuntu/LaDoc/contenu/si/index.md`
- Create: `/home/ubuntu/LaDoc/contenu/si/infrastructure.md`
- Create: `/home/ubuntu/LaDoc/contenu/si/environnements.md`
- Create: `/home/ubuntu/LaDoc/contenu/si/monitoring.md`
- Create: `/home/ubuntu/LaDoc/contenu/si/sauvegardes.md`
- Create: `/home/ubuntu/LaDoc/contenu/si/pieges.md`
- Modify: `/home/ubuntu/LaDoc/contenu/accueil.md` (ajout des liens internes)
- Modify: `/home/ubuntu/LaDoc/sidebars.ts` (réactiver la catégorie SI)
- Delete: `/home/ubuntu/LaDoc/content/` (ancien contenu Hugo)

**Interfaces:**
- Consumes: les pages des tâches 3 à 5, qui deviennent des cibles de liens valides — c'est ce qui permet enfin d'écrire les liens de l'accueil sans casser `onBrokenLinks: 'throw'`.
- Produces: le site complet, prêt à déployer en tâche 8.

- [ ] **Step 1 : Écrire `si/index.md`**

Vue d'ensemble de la couche transverse et tableau des cinq pages de la section.

- [ ] **Step 2 : Écrire `si/infrastructure.md` (anonymisée)**

Décrire : un VPS unique, les applications en conteneurs Docker derrière un Nginx hôte, les certificats TLS, la base Postgres, le service d'analytics auto-hébergé. **Aucune IP, aucun port, aucun chemin serveur.**

Y faire figurer le piège des uploads :

```markdown
:::warning Les images d'upload sont servies par Nginx, pas par l'application
Les fichiers d'upload de LeHub sont servis directement par le Nginx de
l'hôte via un alias de système de fichiers couvrant tout le préfixe, et non
par le conteneur applicatif. Une modification de cette configuration exige
un rechargement de Nginx. Les chemins exacts sont dans LeRunbook.
:::
```

- [ ] **Step 3 : Écrire `si/environnements.md`**

Production et développement : la stack de dev héberge `dev.hub` et `dev.board`, routés par le vrai Nginx et partageant une base unique. Signaler le piège des URLs codées en dur. Pas d'adresses d'accès.

- [ ] **Step 4 : Écrire `si/monitoring.md`**

Le principe : une sonde périodique et un rapport quotidien poussés sur un canal Telegram d'administration, distinct du bot de développement. Décrire ce qui est surveillé et ce que signifie une alerte. Le chemin du script, le chat visé et la crontab sont dans LeRunbook.

- [ ] **Step 5 : Écrire `si/sauvegardes.md`**

Le principe : sauvegarde automatique de la base Postgres et des fichiers d'upload vers un stockage objet externe, avec une clé d'accès **sans droit de suppression** (pour qu'une compromission du serveur ne puisse pas effacer les sauvegardes), et une restauration qui a été testée. La procédure de restauration est dans LeRunbook.

- [ ] **Step 6 : Écrire `si/pieges.md`**

La page la plus utile pour un successeur : la liste consolidée des pièges, chacun sous la forme **symptôme observé → cause → ce qu'il faut faire**. Reprendre au minimum :

1. Administrateurs : `isAdmin=true` mais `role='formateur'` — toujours tester `isAdmin`.
2. Adhérents exclus du Hub, accès minimum = animateur.
3. `hasProHabilitation()` exige ses trois arguments, sinon faux négatif silencieux.
4. Responsable d'un atelier = animateur principal, pas le créateur (`createdById` est vide sur les imports).
5. Nom du cookie de session dupliqué à trois endroits.
6. CSP active en production seulement.
7. Layers CSS : un reset non-layé bat les utilitaires Tailwind layés.
8. Filtrer sur un statut de paiement « payé » fait disparaître les inscrits d'un atelier annulé.
9. Cache bitmap Konva et flou au zoom.
10. CI/CD présent sur les trois apps : ne pas déployer aussi à la main.
11. Uploads servis par Nginx, rechargement requis.
12. Webhook de paiement perdu : un rattrapage quotidien existe.

Chaque piège renvoie en lien vers la page de l'outil concerné.

- [ ] **Step 7 : Ajouter les liens internes à l'accueil**

Reprendre `/home/ubuntu/LaDoc/contenu/accueil.md` et remplacer les mentions en texte simple par de vrais liens (`[LeHub](/lehub/)`, `[LeSite](/lesite/)`, `[LeBoard](/leboard/)`, `[Pièges connus](/si/pieges)`), puis supprimer le commentaire `<!-- liens ajoutés en tâche 6 -->`.

- [ ] **Step 8 : Réactiver la catégorie SI dans la sidebar**

À ce stade, `sidebars.ts` ne contient plus aucune ligne commentée : il est identique à la version écrite en tâche 1, step 6.

- [ ] **Step 9 : Supprimer l'ancien contenu Hugo**

```bash
cd /home/ubuntu/LaDoc && git rm -r -f content
```

- [ ] **Step 10 : Vérifier le build complet**

```bash
cd /home/ubuntu/LaDoc && rm -rf build .docusaurus && npm run build
```

Attendu : `SUCCESS`, sans avertissement de lien cassé.

- [ ] **Step 11 : Vérifier que les 26 pages sont bien générées**

```bash
cd /home/ubuntu/LaDoc && find build -name "index.html" | sort
```

Attendu : la racine, plus les pages des quatre sections. Vérifier qu'aucune page de `docs/superpowers/` n'apparaît dans le build.

- [ ] **Step 12 : Vérifier l'absence de contenu sensible sur tout le contenu**

```bash
cd /home/ubuntu/LaDoc && grep -rnE '([0-9]{1,3}\.){3}[0-9]{1,3}|/var/www|/home/ubuntu|:(3[0-9]{3}|5[0-9]{3})|\.env\.production|chat_id|crontab' contenu/
```

Attendu : aucune correspondance.

- [ ] **Step 13 : Commit**

```bash
cd /home/ubuntu/LaDoc
git add -A
git commit -m "docs(si): section transverse, pièges connus, retrait du contenu Hugo"
```

---

### Task 7 : Repo privé LeRunbook

**Files:**
- Create: `/home/ubuntu/LeRunbook/README.md`
- Create: `/home/ubuntu/LeRunbook/acces.md`
- Create: `/home/ubuntu/LeRunbook/infrastructure.md`
- Create: `/home/ubuntu/LeRunbook/procedures/deployer.md`
- Create: `/home/ubuntu/LeRunbook/procedures/restaurer-un-backup.md`
- Create: `/home/ubuntu/LeRunbook/procedures/alerte-monitoring.md`
- Create: `/home/ubuntu/LeRunbook/procedures/certificats-et-nginx.md`
- Create: `/home/ubuntu/LeRunbook/premier-jour.md`

**Interfaces:**
- Consumes: les pages publiques des tâches 3 à 6, vers lesquelles LeRunbook renvoie par URL absolue (`https://docs.fresquesystemique.org/...`) pour éviter de dupliquer l'explication du fonctionnement.
- Produces: rien pour les tâches suivantes. LeRunbook est en markdown brut lu sur GitHub : pas de générateur de site.

**Contrainte de sécurité :** LeRunbook contient des **emplacements** et des **procédures**, jamais des secrets en clair. Un mot de passe, une clé d'API ou un token ne doit jamais y être écrit — on y écrit où le trouver (gestionnaire de mots de passe, fichier sur le serveur), pas sa valeur.

- [ ] **Step 1 : Créer le repo local**

```bash
mkdir -p /home/ubuntu/LeRunbook/procedures
cd /home/ubuntu/LeRunbook && git init -b master
```

- [ ] **Step 2 : Écrire `README.md`**

```markdown
# LeRunbook

Documentation opérationnelle **privée** du SI de La Fresque Systémique.

La documentation publique (architecture, fonctionnalités, modèles de données,
flux, pièges) est sur https://docs.fresquesystemique.org. Ce repo ne contient
que ce qui ne peut pas être public : accès, infrastructure détaillée et
procédures d'exploitation.

## Règle

Ce repo contient des **emplacements** et des **procédures**, jamais des
secrets en clair. Aucun mot de passe, clé d'API ou token ne doit être commité
ici. On y note où trouver un secret, pas sa valeur.

## Contenu

| Fichier | Contenu |
| --- | --- |
| `premier-jour.md` | Checklist de reprise pour un successeur |
| `acces.md` | Inventaire des accès et où trouver chaque secret |
| `infrastructure.md` | VPS, réseau, ports, chemins, conteneurs, crontabs |
| `procedures/deployer.md` | Déployer chaque application |
| `procedures/restaurer-un-backup.md` | Restaurer la base et les fichiers |
| `procedures/alerte-monitoring.md` | Réagir à une alerte |
| `procedures/certificats-et-nginx.md` | Certificats TLS et configuration Nginx |
```

- [ ] **Step 3 : Écrire `acces.md`**

Un tableau par domaine : VPS et accès SSH, DNS, GitHub (organisation `fresquesystemique` et compte `raphaeldeux`), HelloAsso, Backblaze B2, bots Telegram (celui d'administration et celui de développement, en indiquant lequel sert à quoi), analytics. Pour chaque ligne : à quoi sert l'accès, sous quel compte, **où trouver le secret**. Ajouter une section listant l'emplacement des fichiers `.env` de chaque application sur le serveur.

- [ ] **Step 4 : Écrire `infrastructure.md`**

Ce qui a été retiré du site public : adresse du VPS, ports d'écoute de chaque service, chemins servis par Nginx, dossier des uploads, emplacement des conteneurs et des `docker-compose.yml`, contenu des crontabs (monitoring, nettoyage Docker, sauvegardes, réconciliation), accès à la base de production depuis l'hôte (en notant que le mot de passe se lit dans le `.env` de l'application et doit être encodé pour une URL, et **pas** dans le fichier d'environnement de production).

Y noter aussi le reste à faire connu : la fermeture de l'authentification SSH par mot de passe.

- [ ] **Step 5 : Écrire `procedures/deployer.md`**

Pour chaque application : le déploiement passe par le CI/CD sur push, avec la règle « ne pas déployer aussi à la main ». Puis la procédure manuelle de secours pour les cas où le CI/CD est indisponible, et le cas particulier du site personnel qui n'a pas de CI/CD et se déploie par build et relance manuels. Terminer par la vérification qu'un déploiement est bien passé.

- [ ] **Step 6 : Écrire `procedures/restaurer-un-backup.md`**

La procédure complète et testée : où sont les sauvegardes, comment les récupérer, comment restaurer la base, comment restaurer les fichiers d'upload, comment vérifier. Rappeler que la clé de stockage n'a pas le droit de suppression et ce que cela implique pour la rotation.

- [ ] **Step 7 : Écrire `procedures/alerte-monitoring.md`**

Pour chaque type d'alerte poussée sur le canal Telegram d'administration : ce qu'elle signifie, comment diagnostiquer, comment corriger, quand escalader.

- [ ] **Step 8 : Écrire `procedures/certificats-et-nginx.md`**

Renouvellement des certificats, structure de la configuration Nginx, ajout d'un domaine, rechargement, et le piège des certificats orphelins déjà rencontré.

- [ ] **Step 9 : Écrire `premier-jour.md`**

Checklist ordonnée pour un successeur : récupérer les accès, cloner les repos, lire la doc publique dans l'ordre conseillé, vérifier que le monitoring lui parvient, faire tourner une restauration de sauvegarde à blanc, faire un déploiement sans risque pour valider la chaîne.

- [ ] **Step 10 : Vérifier qu'aucun secret n'a été commité**

```bash
cd /home/ubuntu/LeRunbook && grep -rniE 'password *= *[^ ]|api[_-]?key *= *[^ ]|secret *= *[^ ]|token *= *[a-z0-9]{8}|BEGIN (RSA|OPENSSH) PRIVATE KEY' .
```

Attendu : aucune correspondance. Toute correspondance doit être remplacée par un renvoi vers l'emplacement du secret.

- [ ] **Step 11 : Commit initial**

```bash
cd /home/ubuntu/LeRunbook
git add -A
git commit -m "docs: runbook opérationnel privé v1"
```

- [ ] **Step 12 : Créer le repo distant privé et pousser**

**Demander confirmation à Raphaël avant cette étape** : la création d'un repo distant est une action externe.

```bash
cd /home/ubuntu/LeRunbook
gh repo create LeRunbook --private --source=. --remote=origin --push
```

Vérifier ensuite que la visibilité est bien privée :

```bash
gh repo view LeRunbook --json visibility
```

Attendu : `{"visibility":"PRIVATE"}`. Si le résultat est `PUBLIC`, basculer immédiatement en privé.

---

### Task 8 : Mise en production

**Files:**
- Aucun fichier modifié : cette tâche publie ce qui précède.

**Interfaces:**
- Consumes: le site complet validé en tâche 6 et le script `deploy.sh` de la tâche 1.

- [ ] **Step 1 : Demander la validation de Raphaël**

Lui indiquer que le site est prêt, ce qu'il contient, et attendre son feu vert avant de publier. C'est un remplacement complet du site public existant.

- [ ] **Step 2 : Invoquer la skill de mise en production**

Utiliser la skill `mise-en-prod`, qui porte les conventions de déploiement des projets Fresque Systémique.

- [ ] **Step 3 : Pousser le repo LaDoc**

```bash
cd /home/ubuntu/LaDoc && git push origin master
```

- [ ] **Step 4 : Déployer**

```bash
cd /home/ubuntu/LaDoc && ./deploy.sh
```

Attendu : `✅ Déployé → https://docs.fresquesystemique.org`

- [ ] **Step 5 : Vérifier la production**

```bash
curl -sS -o /dev/null -w "%{http_code}\n" https://docs.fresquesystemique.org/
curl -sS -o /dev/null -w "%{http_code}\n" https://docs.fresquesystemique.org/lehub/donnees
curl -sS -o /dev/null -w "%{http_code}\n" https://docs.fresquesystemique.org/si/pieges
curl -sS https://docs.fresquesystemique.org/ | grep -o "<title>[^<]*</title>"
```

Attendu : trois fois `200`, et un titre contenant `LaDoc`.

- [ ] **Step 6 : Vérifier que la recherche locale fonctionne en production**

```bash
curl -sS -o /dev/null -w "%{http_code}\n" "https://docs.fresquesystemique.org/search?q=badge"
```

Attendu : `200`. Si `404`, l'index de recherche n'a pas été généré au build : relancer `npm run build` (la recherche locale n'est indexée qu'en build de production, pas en `npm start`).

- [ ] **Step 7 : Signaler la mise en ligne à Raphaël**

Message court : ce qui est en ligne, ce qui reste à itérer.
