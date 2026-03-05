defmodule Lifequest.FinancesTest do
  use Lifequest.DataCase

  alias Lifequest.Finances

  describe "financial_profiles" do
    alias Lifequest.Finances.FinancialProfile

    import Lifequest.AccountsFixtures, only: [user_scope_fixture: 0]
    import Lifequest.FinancesFixtures

    @invalid_attrs %{current_savings: nil, current_debts: nil, monthly_debt_payment: nil, net_worth: nil, employment_status: nil}

    test "list_financial_profiles/1 returns all scoped financial_profiles" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)
      other_financial_profile = financial_profile_fixture(other_scope)
      assert Finances.list_financial_profiles(scope) == [financial_profile]
      assert Finances.list_financial_profiles(other_scope) == [other_financial_profile]
    end

    test "get_financial_profile!/2 returns the financial_profile with given id" do
      scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)
      other_scope = user_scope_fixture()
      assert Finances.get_financial_profile!(scope, financial_profile.id) == financial_profile
      assert_raise Ecto.NoResultsError, fn -> Finances.get_financial_profile!(other_scope, financial_profile.id) end
    end

    test "create_financial_profile/2 with valid data creates a financial_profile" do
      valid_attrs = %{current_savings: "120.50", current_debts: "120.50", monthly_debt_payment: "120.50", net_worth: "120.50", employment_status: :cdi}
      scope = user_scope_fixture()

      assert {:ok, %FinancialProfile{} = financial_profile} = Finances.create_financial_profile(scope, valid_attrs)
      assert financial_profile.current_savings == Decimal.new("120.50")
      assert financial_profile.current_debts == Decimal.new("120.50")
      assert financial_profile.monthly_debt_payment == Decimal.new("120.50")
      assert financial_profile.net_worth == Decimal.new("120.50")
      assert financial_profile.employment_status == :cdi
      assert financial_profile.user_id == scope.user.id
    end

    test "create_financial_profile/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.create_financial_profile(scope, @invalid_attrs)
    end


    test "update_financial_profile/3 with valid data updates the financial_profile" do
      scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)
      update_attrs = %{current_savings: "456.70", current_debts: "456.70", monthly_debt_payment: "456.70", net_worth: "456.70", employment_status: :cdd}

      assert {:ok, %FinancialProfile{} = financial_profile} = Finances.update_financial_profile(scope, financial_profile, update_attrs)
      assert financial_profile.current_savings == Decimal.new("456.70")
      assert financial_profile.current_debts == Decimal.new("456.70")
      assert financial_profile.monthly_debt_payment == Decimal.new("456.70")
      assert financial_profile.net_worth == Decimal.new("456.70")
      assert financial_profile.employment_status == :cdd
    end

    test "update_financial_profile/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)

      assert_raise MatchError, fn ->
        Finances.update_financial_profile(other_scope, financial_profile, %{})
      end
    end

    test "update_financial_profile/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Finances.update_financial_profile(scope, financial_profile, @invalid_attrs)
      assert financial_profile == Finances.get_financial_profile!(scope, financial_profile.id)
    end

    test "delete_financial_profile/2 deletes the financial_profile" do
      scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)
      assert {:ok, %FinancialProfile{}} = Finances.delete_financial_profile(scope, financial_profile)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_financial_profile!(scope, financial_profile.id) end
    end

    test "delete_financial_profile/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)
      assert_raise MatchError, fn -> Finances.delete_financial_profile(other_scope, financial_profile) end
    end

    test "change_financial_profile/2 returns a financial_profile changeset" do
      scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)
      assert %Ecto.Changeset{} = Finances.change_financial_profile(scope, financial_profile)
    end
  end
end
