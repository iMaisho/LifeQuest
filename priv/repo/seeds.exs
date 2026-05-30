# Script pour peupler la base de données.
# Idempotent : peut être exécuté plusieurs fois sans erreur.
#
#     mix run priv/repo/seeds.exs

alias Lifequest.Repo
alias Lifequest.Accounts.User

demo_email = "demo@lifequest.fr"
demo_password = "LifeQuest2025!"

%User{}
|> User.email_changeset(%{email: demo_email}, validate_unique: false)
|> User.password_changeset(%{password: demo_password})
|> User.confirm_changeset()
|> Repo.insert!(on_conflict: :nothing, conflict_target: :email)

IO.puts("Compte demo : #{demo_email} / #{demo_password}")
