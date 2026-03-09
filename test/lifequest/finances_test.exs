defmodule Lifequest.FinancesTest do
  use Lifequest.DataCase

  alias Lifequest.Finances

  describe "financial_profiles" do
    alias Lifequest.Finances.FinancialProfile

    import Lifequest.AccountsFixtures, only: [user_scope_fixture: 0]
    import Lifequest.FinancesFixtures

    @invalid_attrs %{
      current_savings: nil,
      current_debts: nil,
      monthly_debt_payment: nil,
      net_worth: nil,
      employment_status: nil
    }

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

      assert_raise Ecto.NoResultsError, fn ->
        Finances.get_financial_profile!(other_scope, financial_profile.id)
      end
    end

    test "create_financial_profile/1 creates a financial_profile" do
      scope = user_scope_fixture()

      assert {:ok, %FinancialProfile{} = financial_profile} =
               Finances.create_financial_profile(scope)

      assert financial_profile.current_savings == Decimal.new("0")
      assert financial_profile.current_debts == Decimal.new("0")
      assert financial_profile.monthly_debt_payment == Decimal.new("0")
      assert financial_profile.net_worth == Decimal.new("0")
      assert financial_profile.employment_status == :cdi
      assert financial_profile.user_id == scope.user.id
    end

    test "create_financial_profile/2 with valid data creates a financial_profile" do
      valid_attrs = %{
        current_savings: "120.500",
        current_debts: "120.500",
        monthly_debt_payment: "120.500",
        net_worth: "120.500",
        employment_status: :cdi
      }

      scope = user_scope_fixture()

      assert {:ok, %FinancialProfile{} = financial_profile} =
               Finances.create_financial_profile(scope, valid_attrs)

      assert financial_profile.current_savings == Decimal.new("120.500")
      assert financial_profile.current_debts == Decimal.new("120.500")
      assert financial_profile.monthly_debt_payment == Decimal.new("120.500")
      assert financial_profile.net_worth == Decimal.new("120.500")
      assert financial_profile.employment_status == :cdi
      assert financial_profile.user_id == scope.user.id
    end

    test "update_financial_profile/3 with valid data updates the financial_profile" do
      scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)

      update_attrs = %{
        current_savings: "456.700",
        current_debts: "456.700",
        monthly_debt_payment: "456.700",
        net_worth: "456.700",
        employment_status: :cdd
      }

      assert {:ok, %FinancialProfile{} = financial_profile} =
               Finances.update_financial_profile(scope, financial_profile, update_attrs)

      assert financial_profile.current_savings == Decimal.new("456.700")
      assert financial_profile.current_debts == Decimal.new("456.700")
      assert financial_profile.monthly_debt_payment == Decimal.new("456.700")
      assert financial_profile.net_worth == Decimal.new("456.700")
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

      assert {:error, %Ecto.Changeset{}} =
               Finances.update_financial_profile(scope, financial_profile, @invalid_attrs)

      assert financial_profile == Finances.get_financial_profile!(scope, financial_profile.id)
    end

    test "delete_financial_profile/2 deletes the financial_profile" do
      scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)

      assert {:ok, %FinancialProfile{}} =
               Finances.delete_financial_profile(scope, financial_profile)

      assert_raise Ecto.NoResultsError, fn ->
        Finances.get_financial_profile!(scope, financial_profile.id)
      end
    end

    test "delete_financial_profile/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)

      assert_raise MatchError, fn ->
        Finances.delete_financial_profile(other_scope, financial_profile)
      end
    end

    test "change_financial_profile/2 returns a financial_profile changeset" do
      scope = user_scope_fixture()
      financial_profile = financial_profile_fixture(scope)
      assert %Ecto.Changeset{} = Finances.change_financial_profile(scope, financial_profile)
    end
  end

  describe "transactions" do
    alias Lifequest.Finances.Transaction

    import Lifequest.AccountsFixtures, only: [user_scope_fixture: 0]
    import Lifequest.FinancesFixtures

    @invalid_attrs %{
      label: nil,
      date: nil,
      direction: nil,
      income_type: nil,
      expense_type: nil,
      amount: nil,
      is_recurring: nil,
      is_active: nil
    }

    test "list_transactions/1 returns all scoped transactions" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      other_transaction = transaction_fixture(other_scope)
      assert Finances.list_transactions(scope) == [transaction]
      assert Finances.list_transactions(other_scope) == [other_transaction]
    end

    test "get_transaction!/2 returns the transaction with given id" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      other_scope = user_scope_fixture()
      assert Finances.get_transaction!(scope, transaction.id) == transaction

      assert_raise Ecto.NoResultsError, fn ->
        Finances.get_transaction!(other_scope, transaction.id)
      end
    end

    test "create_transaction/2 with valid data creates a transaction" do
      scope = user_scope_fixture()
      account = account_fixture(scope)

      valid_attrs = %{
        label: "some label",
        date: ~D[2026-03-05],
        direction: :income,
        income_type: :salary,
        amount: "120.5",
        is_recurring: true,
        is_active: true,
        account_id: account.id
      }

      assert {:ok, %Transaction{} = transaction} = Finances.create_transaction(scope, valid_attrs)

      assert transaction.label == "some label"
      assert transaction.date == ~D[2026-03-05]
      assert transaction.direction == :income
      assert transaction.income_type == :salary
      assert transaction.expense_type == nil
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.is_recurring == true
      assert transaction.is_active == true
      assert transaction.account_id == account.id
    end

    test "create_transaction/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.create_transaction(scope, @invalid_attrs)
    end

    test "update_transaction/3 with valid data updates the transaction" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)

      update_attrs = %{
        label: "some updated label",
        date: ~D[2026-03-06],
        direction: :expense,
        income_type: :freelance,
        expense_type: :pleasure,
        amount: "456.7",
        is_recurring: false,
        is_active: false
      }

      assert {:ok, %Transaction{} = transaction} =
               Finances.update_transaction(scope, transaction, update_attrs)

      assert transaction.label == "some updated label"
      assert transaction.date == ~D[2026-03-06]
      assert transaction.direction == :expense
      assert transaction.income_type == nil
      assert transaction.expense_type == :pleasure
      assert transaction.amount == Decimal.new("456.7")
      assert transaction.is_recurring == false
      assert transaction.is_active == false
    end

    test "update_transaction/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      transaction = transaction_fixture(scope)

      assert_raise Ecto.NoResultsError, fn ->
        Finances.update_transaction(other_scope, transaction, %{})
      end
    end

    test "update_transaction/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Finances.update_transaction(scope, transaction, @invalid_attrs)

      assert transaction == Finances.get_transaction!(scope, transaction.id)
    end

    test "delete_transaction/2 deletes the transaction" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      assert {:ok, %Transaction{}} = Finances.delete_transaction(scope, transaction)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_transaction!(scope, transaction.id) end
    end

    test "delete_transaction/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      transaction = transaction_fixture(scope)

      assert_raise Ecto.NoResultsError, fn ->
        Finances.delete_transaction(other_scope, transaction)
      end
    end

    test "change_transaction/2 returns a transaction changeset" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      assert %Ecto.Changeset{} = Finances.change_transaction(scope, transaction)
    end
  end

  describe "accounts" do
    alias Lifequest.Finances.Account

    import Lifequest.AccountsFixtures, only: [user_scope_fixture: 0]
    import Lifequest.FinancesFixtures

    @invalid_attrs %{label: nil, type: nil, balance: nil, interest_rate: nil, is_active: nil}

    test "list_accounts/1 returns all scoped accounts" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      account = account_fixture(scope)
      other_account = account_fixture(other_scope)
      assert Finances.list_accounts(scope) == [account]
      assert Finances.list_accounts(other_scope) == [other_account]
    end

    test "get_account!/2 returns the account with given id" do
      scope = user_scope_fixture()
      account = account_fixture(scope)
      other_scope = user_scope_fixture()
      assert Finances.get_account!(scope, account.id) == account
      assert_raise Ecto.NoResultsError, fn -> Finances.get_account!(other_scope, account.id) end
    end

    test "create_account/2 with valid data creates a account" do
      valid_attrs = %{
        label: "some label",
        type: :checking,
        balance: "120.5",
        interest_rate: "120.5",
        is_active: true
      }

      scope = user_scope_fixture()

      assert {:ok, %Account{} = account} = Finances.create_account(scope, valid_attrs)
      assert account.label == "some label"
      assert account.type == :checking
      assert account.balance == Decimal.new("120.5")
      assert account.interest_rate == Decimal.new("120.5")
      assert account.is_active == true
      assert account.user_id == scope.user.id
    end

    test "create_account/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.create_account(scope, @invalid_attrs)
    end

    test "update_account/3 with valid data updates the account" do
      scope = user_scope_fixture()
      account = account_fixture(scope)

      update_attrs = %{
        label: "some updated label",
        type: :savings,
        balance: "456.7",
        interest_rate: "456.7",
        is_active: false
      }

      assert {:ok, %Account{} = account} = Finances.update_account(scope, account, update_attrs)
      assert account.label == "some updated label"
      assert account.type == :savings
      assert account.balance == Decimal.new("456.7")
      assert account.interest_rate == Decimal.new("456.7")
      assert account.is_active == false
    end

    test "update_account/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      account = account_fixture(scope)

      assert_raise MatchError, fn ->
        Finances.update_account(other_scope, account, %{})
      end
    end

    test "update_account/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      account = account_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Finances.update_account(scope, account, @invalid_attrs)
      assert account == Finances.get_account!(scope, account.id)
    end

    test "delete_account/2 deletes the account" do
      scope = user_scope_fixture()
      account = account_fixture(scope)
      assert {:ok, %Account{}} = Finances.delete_account(scope, account)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_account!(scope, account.id) end
    end

    test "delete_account/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      account = account_fixture(scope)
      assert_raise MatchError, fn -> Finances.delete_account(other_scope, account) end
    end

    test "change_account/2 returns a account changeset" do
      scope = user_scope_fixture()
      account = account_fixture(scope)
      assert %Ecto.Changeset{} = Finances.change_account(scope, account)
    end
  end
end
