defmodule Lifequest.FinancesDeleteTest do
  use Lifequest.DataCase, async: true

  import Lifequest.AccountsFixtures
  import Lifequest.FinancesFixtures

  alias Lifequest.Finances
  alias Lifequest.Repo
  alias Lifequest.Finances.{Account, FinancialProfile, Transaction}

  describe "delete_all_user_data/1" do
    test "deletes accounts, transactions and financial profile for the scope" do
      scope = user_scope_fixture()
      financial_profile_fixture(scope)
      transaction_fixture(scope)

      assert :ok = Finances.delete_all_user_data(scope)

      assert Repo.all(from a in Account, where: a.user_id == ^scope.user.id) == []

      assert Repo.all(
               from t in Transaction,
                 join: a in Account,
                 on: t.account_id == a.id,
                 where: a.user_id == ^scope.user.id
             ) == []

      assert Repo.all(from fp in FinancialProfile, where: fp.user_id == ^scope.user.id) == []
    end

    test "does not delete data belonging to another user" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      financial_profile_fixture(other_scope)
      transaction_fixture(other_scope)

      assert :ok = Finances.delete_all_user_data(scope)

      assert Repo.all(from a in Account, where: a.user_id == ^other_scope.user.id) != []

      assert Repo.all(from fp in FinancialProfile, where: fp.user_id == ^other_scope.user.id) !=
               []
    end

    test "returns :ok when user has no data" do
      scope = user_scope_fixture()
      assert :ok = Finances.delete_all_user_data(scope)
    end
  end
end
