# Lifequest

Application de gestion financière personnelle construite avec Phoenix LiveView (Elixir), PostgreSQL et une authentification par magic link.

## Lancer le projet avec Docker

La méthode la plus simple, sans installer Elixir ni PostgreSQL :

```bash
docker compose up --build
```

L'application est accessible sur [http://localhost:4000](http://localhost:4000).

Au premier démarrage, l'image Docker est construite (quelques minutes). Les migrations et les seeds sont joués automatiquement avant le démarrage du serveur.

Compte de démonstration créé par les seeds :

- Email : `demo@lifequest.fr`
- Mot de passe : `LifeQuest2025!`

## Lancer le projet en développement local

Prérequis : Elixir 1.18+, PostgreSQL 16.

```bash
mix setup        # installe les dépendances, crée et migre la base de données
mix phx.server   # démarre le serveur sur localhost:4000
```

Le même compte de démonstration est disponible après `mix setup`.

## Commandes utiles

```bash
mix test              # lance la suite de tests
mix precommit         # format + credo + tests (à lancer avant chaque commit)
mix ecto.reset        # recrée la base de données depuis zéro
```

## Variables d'environnement

Voir `.env.example` pour la liste complète des variables requises en production.
