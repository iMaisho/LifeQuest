# Rapport de projet — Titre Professionnel Concepteur Développeur d'Applications

**Candidat** : Antonin MINGAM
**Titre visé** : Concepteur Développeur d'Applications Niveau 6
**Référentiel** : TP-01281 millésime 04 (24/05/2023)
**Projet support** : Lifequest - Application de gestion financière personnelle

---

## Sommaire

1. [Présentation du candidat et du contexte de formation](#1-présentation-du-candidat-et-du-contexte-de-formation)
2. [Présentation du projet Lifequest](#2-présentation-du-projet-lifequest)
   - 2.1 [Contexte et objectifs](#21-contexte-et-objectifs)
   - 2.2 [Stack technique](#22-stack-technique)
   - 2.3 [Architecture générale](#23-architecture-générale)

---

### BLOC 1 — Développer une application sécurisée

3. [CP1 — Installer et configurer son environnement de travail en fonction du projet](#3-cp1--installer-et-configurer-son-environnement-de-travail-en-fonction-du-projet)
   - 3.1 [Environnement de développement](#31-environnement-de-développement)
   - 3.2 [Outils de gestion des versions et de collaboration](#32-outils-de-gestion-des-versions-et-de-collaboration)
   - 3.3 [Conteneurisation](#33-conteneurisation)

4. [CP2 — Développer des interfaces utilisateur](#4-cp2--développer-des-interfaces-utilisateur)
   - 4.1 [Conception des interfaces avec Phoenix LiveView](#41-conception-des-interfaces-avec-phoenix-liveview)
   - 4.2 [Charte graphique et responsive design (Tailwind CSS / daisyUI)](#42-charte-graphique-et-responsive-design-tailwind-css--daisyui)
   - 4.3 [Accessibilité (RGAA)](#43-accessibilité-rgaa)
   - 4.4 [Conformité RGPD — Mentions légales](#44-conformité-rgpd--mentions-légales)
   - 4.5 [Tests des composants d'interface](#45-tests-des-composants-dinterface)
   - 4.6 [Sécurité des interfaces (XSS, CSRF)](#46-sécurité-des-interfaces-xss-csrf)

5. [CP3 — Développer des composants métier](#5-cp3--développer-des-composants-métier)
   - 5.1 [Architecture en contextes (Finances, Accounts)](#51-architecture-en-contextes-finances-accounts)
   - 5.2 [Développement défensif et gestion des erreurs](#52-développement-défensif-et-gestion-des-erreurs)
   - 5.3 [Communication en temps réel avec Phoenix PubSub](#53-communication-en-temps-réel-avec-phoenix-pubsub)
   - 5.4 [Tests unitaires des composants métier](#54-tests-unitaires-des-composants-métier)
   - 5.5 [Sécurité des composants métier](#55-sécurité-des-composants-métier)

6. [CP4 — Contribuer à la gestion d'un projet informatique](#6-cp4--contribuer-à-la-gestion-dun-projet-informatique)
   - 6.1 [Méthode de développement itérative](#61-méthode-de-développement-itérative)
   - 6.2 [Planification et suivi des tâches (Jira)](#62-planification-et-suivi-des-tâches-jira)
   - 6.3 [Outils collaboratifs (GitHub, conventions de commits)](#63-outils-collaboratifs-github-conventions-de-commits)
   - 6.4 [Qualité du code (Credo, mix format, CI)](#64-qualité-du-code-credo-mix-format-ci)

---

### BLOC 2 — Concevoir et développer une application sécurisée organisée en couches

7. [CP5 — Analyser les besoins et maquetter une application](#7-cp5--analyser-les-besoins-et-maquetter-une-application)
   - 7.1 [Analyse du cahier des charges et identification des besoins](#71-analyse-du-cahier-des-charges-et-identification-des-besoins)
   - 7.2 [User stories](#72-user-stories)
   - 7.3 [Maquettes et enchaînement des écrans](#73-maquettes-et-enchaînement-des-écrans)
   - 7.4 [Dossier de conception](#74-dossier-de-conception)

8. [CP6 — Définir l'architecture logicielle d'une application](#8-cp6--définir-larchitecture-logicielle-dune-application)
   - 8.1 [Architecture multicouche (web / contextes / schémas)](#81-architecture-multicouche-web--contextes--schémas)
   - 8.2 [Choix du framework et de l'ORM (Phoenix / Ecto)](#82-choix-du-framework-et-de-lorm-phoenix--ecto)
   - 8.3 [Stratégie de sécurité par couche](#83-stratégie-de-sécurité-par-couche)
   - 8.4 [Éco-conception](#84-éco-conception)

9. [CP7 — Concevoir et mettre en place une base de données relationnelle](#9-cp7--concevoir-et-mettre-en-place-une-base-de-données-relationnelle)
   - 9.1 [Modèle Conceptuel de Données (MCD)](#91-modèle-conceptuel-de-données-mcd)
   - 9.2 [Modèle Physique de Données (MPD)](#92-modèle-physique-de-données-mpd)
   - 9.3 [Migrations Ecto et scripts de création](#93-migrations-ecto-et-scripts-de-création)
   - 9.4 [Sécurité et droits d'accès](#94-sécurité-et-droits-daccès)
   - 9.5 [Jeu d'essai](#95-jeu-dessai)

10. [CP8 — Développer des composants d'accès aux données SQL et NoSQL](#10-cp8--développer-des-composants-daccès-aux-données-sql-et-nosql)
    - 10.1 [Requêtes Ecto (CRUD sécurisé)](#101-requêtes-ecto-crud-sécurisé)
    - 10.2 [Gestion de l'intégrité et des conflits d'accès (transactions)](#102-gestion-de-lintégrité-et-des-conflits-daccès-transactions)
    - 10.3 [Validation et contrôle des entrées côté serveur](#103-validation-et-contrôle-des-entrées-côté-serveur)
    - 10.4 [Tests unitaires et de sécurité des accès aux données](#104-tests-unitaires-et-de-sécurité-des-accès-aux-données)
    - 10.5 [Protection contre l'injection SQL](#105-protection-contre-linjection-sql)

---

### BLOC 3 — Préparer le déploiement d'une application sécurisée

11. [CP9 — Préparer et exécuter les plans de tests d'une application](#11-cp9--préparer-et-exécuter-les-plans-de-tests-dune-application)
    - 11.1 [Plan de tests](#111-plan-de-tests)
    - 11.2 [Tests unitaires (ExUnit)](#112-tests-unitaires-exunit)
    - 11.3 [Tests d'intégration (LiveView)](#113-tests-dintégration-liveview)
    - 11.4 [Tests de sécurité](#114-tests-de-sécurité)
    - 11.5 [Résultats et compte-rendu de tests](#115-résultats-et-compte-rendu-de-tests)

12. [CP10 — Préparer et documenter le déploiement d'une application](#12-cp10--préparer-et-documenter-le-déploiement-dune-application)
    - 12.1 [Environnements (développement, test, production)](#121-environnements-développement-test-production)
    - 12.2 [Procédure de déploiement](#122-procédure-de-déploiement)
    - 12.3 [Scripts de déploiement et migrations](#123-scripts-de-déploiement-et-migrations)
    - 12.4 [Variables d'environnement et configuration](#124-variables-denvironnement-et-configuration)

13. [CP11 — Contribuer à la mise en production dans une démarche DevOps](#13-cp11--contribuer-à-la-mise-en-production-dans-une-démarche-devops)
    - 13.1 [Pipeline CI/CD (GitHub Actions)](#131-pipeline-cicd-github-actions)
    - 13.2 [Conteneurisation (Docker)](#132-conteneurisation-docker)
    - 13.3 [Outils de qualité de code (Credo, mix format)](#133-outils-de-qualité-de-code-credo-mix-format)
    - 13.4 [Automatisation des tests](#134-automatisation-des-tests)
    - 13.5 [Interprétation des rapports CI](#135-interprétation-des-rapports-ci)

---

### Compétences transversales

14. [Communiquer en français et en anglais](#14-communiquer-en-français-et-en-anglais)
    - 14.1 [Documentation technique en anglais](#141-documentation-technique-en-anglais)
    - 14.2 [Lecture de documentation technique en anglais (niveau B1)](#142-lecture-de-documentation-technique-en-anglais-niveau-b1)

15. [Mettre en œuvre une démarche de résolution de problème](#15-mettre-en-œuvre-une-démarche-de-résolution-de-problème)

16. [Apprendre en continu — Veille technologique](#16-apprendre-en-continu--veille-technologique)

---

17. [Conclusion et bilan de compétences](#17-conclusion-et-bilan-de-compétences)
18. [Annexes](#18-annexes)
    - A. Diagramme MCD / MPD
    - B. Maquettes des interfaces
    - C. Plan de tests complet
    - D. Extraits de code commentés
    - E. Captures d'écran de l'application

---

## 1. Présentation du candidat et du contexte de formation

Avant d'entrer en formation, mon parcours étudiant et professionnel ont été un long processus exploratoire. Après une scolarité exemplaire, j'ai traversé plusieurs filières "sérieuse" avant de succomber au choix du coeur. J'ai finalement jeté mon dévolu sur une carrière mêlant technique et artistique, en tant qu'ingénieur du son. J'ai exercé cette activité pendant 5 ans en autoentreprise, acquérant au passage des compétences techniques et transversales, d'autonomie et de gestion d'entreprise.
Mon choix de changer de direction arrive à la rencontre de plusieurs évènements simultanés dans ma vie d'entrepreneur :

- la sensation d'avoir atteint un plafond de verre
- la frustration de ne pas avoir de diplôme qualifiant
- l'arrivée imminente de mes 30 ans
- la rencontre avec le monde du développement
  En effet, malgré une rapide découverte au cours de mon adolescence, je n'avais jamais vraiment compris ce monde si vaste et riche. Mais lors de mon parcours, j'ai été amené à rédiger des newsletters en HTML/CSS d'abord, puis à vouloir refondre mon site web professionnel qui avait été créé grâce à un outil no-code à l'origine. J'ai fini par consacrer une grande partie de mon temps libre à l'apprentissage des bases du développement, grâce aux cours en ligne d'OpenClassrooms puis de l'université d'Harvard. Cette montée en compétences progressive m'a convaincu de mon attrait pour le développement, et de ma motivation à concrétiser ces nouvelles compétences grâce à des études traditionnelles.
  C'est dans la suite logique de ma formation en autodidacte que j'ai décidé d'intégrer la 2iAcademy en Conception et Developpement d'Applications et en alternance chez Frixel afin de renforcer mes compétences et d'en acquérir de nouvelles en conception, ainsi que d'obtenir un diplôme reconnu et qualifiant.
  À l'issue de cette formation, je poursuivrai au sein de l'ESGI Paris en Mastère Big Data & Intelligence Artificielle dans le but de me spécialiser dans un secteur en forte croissance. À plus long terme, je me réserve le droit de retrouver le chemin de l'entrepreneuriat, fort cette fois d'une double compétence technique et d'un diplôme reconnu.

## 2. Présentation du projet Lifequest

### 2.1 Contexte et objectifs

Durant mon activité entrepreneuriale, il était très compliqué de me projeter dans l'avenir à moyen ou long terme. Mon arrivée dans un univers professionnel stable m'a permis de découvrir la gestion d'épargne à long terme, les objectifs financiers et les placements financiers.
En explorant le sujet, j'ai découvert beaucoup d'applications de gestion financière et de placements financiers, mais aucune qui permettait de faire les deux à la fois, en plus d'offrir du conseil en gestion de patrimoine.
Un ami travaillant dans la finance m'avait fait part de son idée d'application de gestion et de conseil financiers, et une connaissance japonaise m'a fait découvrir des outils de gestion financière répandus au Japon. Ces différents échanges ont fait émerger l'idée de Lifequest, avec une approche innovante articulée autour des objectifs de vie de l'utilisateur, comme un achat de maison ou la volonté d'avoir un enfant.
L'utilisateur renseigne sa situation financière actuelle, une estimation de ses revenus et de ses dépenses mensuels. Cela nous permet de prendre une photo de son patrimoine et d'effectuer des projections du futur simplement.
Il définit ensuite un objectif représenté par un montant cible et une échéance. À partir de ces données, l'application génère des recommandations personnalisées : réduction des dépenses non essentielles, placements ponctuels ou réguliers, avec un niveau de risque adapté à la complexité de l'objectif et à la situation financière déclarée.

L'application cible des particuliers souhaitant gérer leur budget personnel et planifier des objectifs financiers à moyen ou long terme, sans nécessiter de connaissances préalables en finance.

### 2.2 Stack technique

- Backend : Elixir 1.18 / OTP 27, Phoenix 1.8, Phoenix LiveView 1.1, Ecto
- Base de données : PostgreSQL 16
- Frontend : Tailwind CSS v4, daisyUI, templates HEEx (pas de framework JS séparé)
- Tests : ExUnit, ConnCase, Phoenix.LiveViewTest
- CI : GitHub Actions

Le choix de cette stack technique s'est présentée comme une évidence, car c'est celle que j'ai apprise et sur laquelle j'ai travaillé durant la majorité de mon alternance chez Frixel. Le framework Phoenix est très complet, innovant, et bien conçu. La séparation des responsabilités est très claire (contexts, schemas, controllers, LiveViews), les outils intégrés sont très riches, et LiveView permet de construire des interfaces réactives côté serveur sans avoir à maintenir un framework JavaScript séparé.

Côté données, Phoenix fournit l'ORM Ecto, conçu pour fonctionner par défaut avec PostGreSQL, avec un système de migrations versionné et les changesets qui permettent la validation des données avant toute écriture en base.

`mix phx.gen.auth` nous fournit un système d'authentification poussé en une commande, avec stockage des mots de passes hashés avec bcrypt en base, ainsi que le magic link, un système de vérification de compte et de réinitialisation de mot de passe grâce à un envoi de token par email.

Les tests s'appuient sur ExUnit pour les tests unitaires, ConnCase pour les routes HTTP et Phoenix.LiveViewTest pour les interactions LiveView.

L'intégration continue est assurée par GitHub Actions, dont le pipeline exécute les tâches d'installation et de validation fournies par l'écosystème Phoenix : `mix format --check-formatted` et `mix credo --strict` pour le linting et le formatage, `mix test` pour l'exécution des tests et `mix compile --warnings-as-errors` pour la compilation stricte du projet.

### 2.3 Architecture générale

Lifequest repose sur une architecture en trois couches strictement séparées, afin de respecter la convention proposée par le framework.

**Couche présentation :** HEEx est un language de templating permettant de construire nos pages webs en Elixir. Ce sont les LiveViews qui sont chargées d'interpréter ce code. Lors de leur création, un état est généré côté serveur et une Websocket persistante est ouverte pour communiquer avec le navigateur. Les interactions utilisateur déclenchent des évènements traités par le serveur qui renvoie le diff partiel du DOM, permettant de changer l'interface sans rechargement de la page.

**Couche métier :** Ce sont les contextes Elixir qui portent ces responsabilités. Chaque contexte expose des fonctions publiques qui pourront être appelées par l'ensemble des LiveView. Ces dernières doivent passer par les fonctions des contextes pour interagir avec la base de données. Cela centralise la logique métier, et facilite les tests.

**Couche données :** Les schémas Ecto définissent la structure des données et les changesets qui valident les entrées avant toute écriture. Ecto génère des requêtes paramétrées afin d'éviter les injections SQL.

Une autre fonctionnalité offerte par Phoenix s'appelle Scope. Il s'agit d'une struct représentant l'utilisateur actuel qui est passée en premier argument à toutes les fonctions de contexte. Cela garantit l'isolation des données entre les utilisateurs, car elle est utilisée comme filtre dans toutes les requêtes Ecto. On peut également s'appuyer sur elle pour la gestion des droits, par exemple entre admin et user, ou entre compte free ou premium.

Pour résumer, à l'appel d'une route :

- la requête HTTP initiale déclenche le `mount/3` de la LiveView
- les fonctions de contextes nécessaires au rendu initial sont appelées
- les requêtes SQL sont envoyées à PostgreSQL grâce à Ecto
- les données sont placées en assigns sur la socket et stockées en mémoire vive
- le template HEEx s'affiche, en utilisant ces données

Par la suite, les interactions utilisateurs déclencheront des fonctions `handle_event/3` qui fonctionnent de manière similaire, et qui permettront de modifier le DOM sans rechargement ou d'émettre des messages PubSub pour avertir d'autres LiveViews abonnées de la mise à jour de leur état en temps réel grâce à `handle_info/3`
