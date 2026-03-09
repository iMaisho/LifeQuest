defmodule Lifequest.Repo.Migrations.UpdateTransactionsAddAccountRemoveUser do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all),
        null: false

      remove :user_id, references(:users, type: :binary_id)
    end

    create index(:transactions, [:account_id])
  end
end
