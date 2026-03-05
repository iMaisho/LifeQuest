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
      valid_attrs = %{current_savings: "120.500", current_debts: "120.500", monthly_debt_payment: "120.500", net_worth: "120.500", employment_status: :cdi}
      scope = user_scope_fixture()

      assert {:ok, %FinancialProfile{} = financial_profile} = Finances.create_financial_profile(scope, valid_attrs)
      assert financial_profile.current_savings == Decimal.new("120.500")
      assert financial_profile.current_debts == Decimal.new("120.500")
      assert financial_profile.monthly_debt_payment == Decimal.new("120.500")
      assert financial_profile.net_worth == Decimal.new("120.500")
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
      update_attrs = %{current_savings: "456.700", current_debts: "456.700", monthly_debt_payment: "456.700", net_worth: "456.700", employment_status: :cdd}

      assert {:ok, %FinancialProfile{} = financial_profile} = Finances.update_financial_profile(scope, financial_profile, update_attrs)
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

  describe "income_streams" do
    alias Lifequest.Finances.IncomeStream

    import Lifequest.AccountsFixtures, only: [user_scope_fixture: 0]
    import Lifequest.FinancesFixtures

    @invalid_attrs %{label: nil, type: nil, amount: nil, frequency: nil, start_date: nil, end_date: nil, is_active: nil}

    test "list_income_streams/1 returns all scoped income_streams" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      income_stream = income_stream_fixture(scope)
      other_income_stream = income_stream_fixture(other_scope)
      assert Finances.list_income_streams(scope) == [income_stream]
      assert Finances.list_income_streams(other_scope) == [other_income_stream]
    end

    test "get_income_stream!/2 returns the income_stream with given id" do
      scope = user_scope_fixture()
      income_stream = income_stream_fixture(scope)
      other_scope = user_scope_fixture()
      assert Finances.get_income_stream!(scope, income_stream.id) == income_stream
      assert_raise Ecto.NoResultsError, fn -> Finances.get_income_stream!(other_scope, income_stream.id) end
    end

    test "create_income_stream/2 with valid data creates a income_stream" do
      valid_attrs = %{label: "some label", type: :salary, amount: "120.50", frequency: :weekly, start_date: ~D[2026-03-04], end_date: ~D[2026-03-04], is_active: true}
      scope = user_scope_fixture()

      assert {:ok, %IncomeStream{} = income_stream} = Finances.create_income_stream(scope, valid_attrs)
      assert income_stream.label == "some label"
      assert income_stream.type == :salary
      assert income_stream.amount == Decimal.new("120.50")
      assert income_stream.frequency == :weekly
      assert income_stream.start_date == ~D[2026-03-04]
      assert income_stream.end_date == ~D[2026-03-04]
      assert income_stream.is_active == true
      assert income_stream.user_id == scope.user.id
    end

    test "create_income_stream/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.create_income_stream(scope, @invalid_attrs)
    end

    test "update_income_stream/3 with valid data updates the income_stream" do
      scope = user_scope_fixture()
      income_stream = income_stream_fixture(scope)
      update_attrs = %{label: "some updated label", type: :freelance, amount: "456.70", frequency: :monthly, start_date: ~D[2026-03-05], end_date: ~D[2026-03-05], is_active: false}

      assert {:ok, %IncomeStream{} = income_stream} = Finances.update_income_stream(scope, income_stream, update_attrs)
      assert income_stream.label == "some updated label"
      assert income_stream.type == :freelance
      assert income_stream.amount == Decimal.new("456.70")
      assert income_stream.frequency == :monthly
      assert income_stream.start_date == ~D[2026-03-05]
      assert income_stream.end_date == ~D[2026-03-05]
      assert income_stream.is_active == false
    end

    test "update_income_stream/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      income_stream = income_stream_fixture(scope)

      assert_raise MatchError, fn ->
        Finances.update_income_stream(other_scope, income_stream, %{})
      end
    end

    test "update_income_stream/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      income_stream = income_stream_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Finances.update_income_stream(scope, income_stream, @invalid_attrs)
      assert income_stream == Finances.get_income_stream!(scope, income_stream.id)
    end

    test "delete_income_stream/2 deletes the income_stream" do
      scope = user_scope_fixture()
      income_stream = income_stream_fixture(scope)
      assert {:ok, %IncomeStream{}} = Finances.delete_income_stream(scope, income_stream)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_income_stream!(scope, income_stream.id) end
    end

    test "delete_income_stream/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      income_stream = income_stream_fixture(scope)
      assert_raise MatchError, fn -> Finances.delete_income_stream(other_scope, income_stream) end
    end

    test "change_income_stream/2 returns a income_stream changeset" do
      scope = user_scope_fixture()
      income_stream = income_stream_fixture(scope)
      assert %Ecto.Changeset{} = Finances.change_income_stream(scope, income_stream)
    end
  end
end
