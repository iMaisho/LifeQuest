# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)

## [Unreleased]

### Added
- Page de simulation d'objectifs financiers : faisabilité, scénario optimal (du plus sûr au plus risqué) et montant mensuel manquant si l'objectif est hors de portée
- Graphiques donut SVG natifs sur le dashboard : répartition des revenus et dépenses par type
- Bloc balance mensuelle numérique (total revenus, total dépenses, solde coloré)
- Filtrage des transactions par catégorie avec persistance dans l'URL
- Badge de catégorie coloré dans la liste des transactions
- Synthèse des totaux par catégorie sur la page finances
- Bloc "Top catégories de dépenses" sur le dashboard
- Page de simulation de placements : placement sûr (3%/an garanti) et placement risqué avec fourchette pessimiste/attendu/optimiste, virement mensuel et horizon personnalisable

## [0.5.0] - 2025-04-24

### Added
- Navigation principale avec layout restructuré (LQ-17)
- Page de création du profil financier avec saisie des économies et dettes (LQ-6)
- Schéma Account pour relier les utilisateurs à leurs transactions (LQ-46)
- Dashboard basique avec vue d'ensemble financière (LQ-14)

### Changed
- Remplacement des modèles IncomeStream et Expense par un modèle Transaction unifié (LQ-5)
