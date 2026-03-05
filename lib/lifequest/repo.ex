defmodule Lifequest.Repo do
  use Ecto.Repo,
    otp_app: :lifequest,
    adapter: Ecto.Adapters.Postgres
end
