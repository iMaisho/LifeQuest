defmodule LifequestWeb.LegalLive.Index do
  use LifequestWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto py-10 px-4 space-y-10">
        <div>
          <h1 class="text-3xl font-bold mb-2">{gettext("Legal notice & Privacy policy")}</h1>
          <p class="text-sm opacity-50">{gettext("Last updated: May 2025")}</p>
        </div>

        <section class="space-y-3">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            {gettext("1. Data controller")}
          </h2>
          <p>
            {gettext(
              "This application is developed and operated by Antonin Mingam as part of a vocational training project (CDA — Concepteur Développeur d'Applications). It is not a commercial service."
            )}
          </p>
          <p class="font-medium">{gettext("Contact: contact@lifequest.com")}</p>
        </section>

        <section class="space-y-3">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            {gettext("2. Data collected")}
          </h2>
          <p>{gettext("Lifequest collects only the data you explicitly provide:")}</p>
          <ul class="space-y-2 pl-4">
            <li>
              <span class="font-semibold">{gettext("Email address")} :</span>
              {gettext("used solely for authentication via magic link. No password is stored.")}
            </li>
            <li>
              <span class="font-semibold">{gettext("Financial profile")} :</span>
              {gettext("current savings, debts, monthly repayment, net worth and employment status.")}
            </li>
            <li>
              <span class="font-semibold">{gettext("Bank accounts")} :</span>
              {gettext("label and type (bank account or investment).")}
            </li>
            <li>
              <span class="font-semibold">{gettext("Transactions")} :</span>
              {gettext("label, amount, date, category (income or expense) and recurrence status.")}
            </li>
            <li>
              <span class="font-semibold">{gettext("Financial goals")} :</span>
              {gettext("name, target amount and deadline.")}
            </li>
          </ul>
          <p class="opacity-70 text-sm">
            {gettext(
              "No payment data, no social security number, no sensitive data within the meaning of Article 9 of the GDPR is collected."
            )}
          </p>
        </section>

        <section class="space-y-3">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            {gettext("3. Purpose and legal basis")}
          </h2>
          <p>
            {gettext(
              "The data is processed solely to provide the features of the application: projections, goal tracking and financial summaries. The legal basis is the performance of a contract (Article 6(1)(b) GDPR): by creating an account, you accept that your data be processed in order to use the service."
            )}
          </p>
        </section>

        <section class="space-y-3">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            {gettext("4. Data retention")}
          </h2>
          <p>
            {gettext(
              "Your data is kept for as long as your account is active. If you delete your account, all associated data (profile, accounts, transactions, goals) is permanently deleted from our database. Authentication tokens expire automatically after 60 days."
            )}
          </p>
        </section>

        <section class="space-y-3">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            {gettext("5. Data sharing")}
          </h2>
          <p>
            {gettext(
              "Your data is never sold, rented or shared with third parties. The application does not integrate any advertising or analytics tracking service. The only sub-processor is the hosting provider, which stores the PostgreSQL database."
            )}
          </p>
        </section>

        <section class="space-y-3">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            {gettext("6. Security")}
          </h2>
          <p>
            {gettext(
              "All exchanges between your browser and the server are encrypted via HTTPS. Each user's data is strictly isolated: every database query is filtered by an authenticated scope, making it technically impossible to access another user's data. No password is stored — authentication relies exclusively on single-use tokens sent by email."
            )}
          </p>
        </section>

        <section class="space-y-3">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            {gettext("7. Cookies and local storage")}
          </h2>
          <p>{gettext("Lifequest uses:")}</p>
          <ul class="space-y-2 pl-4">
            <li>
              <span class="font-semibold">{gettext("A session cookie")} :</span>
              {gettext(
                "required for CSRF protection and session management. It is deleted when you log out."
              )}
            </li>
            <li>
              <span class="font-semibold">
                {gettext("A localStorage entry")} (<code class="text-sm bg-base-300 px-1 rounded">phx:theme</code>) :
              </span>
              {gettext(
                "stores your theme preference (light, dark or system) locally in your browser. It contains no personal data."
              )}
            </li>
          </ul>
          <p class="opacity-70 text-sm">{gettext("No advertising or analytics cookies are used.")}</p>
        </section>

        <section class="space-y-3">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            {gettext("8. Your rights")}
          </h2>
          <p>
            {gettext("Under the GDPR, you have the following rights regarding your personal data:")}
          </p>
          <ul class="space-y-2 pl-4">
            <li>
              <span class="font-semibold">{gettext("Right of access")} :</span>
              {gettext("you can consult all your data directly in the application.")}
            </li>
            <li>
              <span class="font-semibold">{gettext("Right to rectification")} :</span>
              {gettext("you can edit your data at any time from the settings.")}
            </li>
            <li>
              <span class="font-semibold">{gettext("Right to erasure")} :</span>
              {gettext("you can delete your account and all associated data from the settings page.")}
            </li>
            <li>
              <span class="font-semibold">{gettext("Right to data portability")} :</span>
              {gettext("you may request an export of your data by contacting us.")}
            </li>
            <li>
              <span class="font-semibold">{gettext("Right to object")} :</span>
              {gettext(
                "you may object to the processing of your data at any time by deleting your account."
              )}
            </li>
          </ul>
          <p>{gettext("To exercise these rights, contact us at: contact@lifequest.com")}</p>
          <p>
            {gettext(
              "You also have the right to lodge a complaint with the CNIL (Commission Nationale de l'Informatique et des Libertés): www.cnil.fr"
            )}
          </p>
        </section>

        <section class="space-y-3">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            {gettext("9. Changes to this policy")}
          </h2>
          <p>
            {gettext(
              "This policy may be updated. Any significant change will be communicated via the application. Continued use of the service after an update constitutes acceptance of the new policy."
            )}
          </p>
        </section>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, gettext("Legal notice"))}
  end
end
