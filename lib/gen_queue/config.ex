defmodule GenQueue.Config do
  def get(otp_app, key, default \\ nil) do
    Application.get_env(otp_app, key, default)
  end

  def adapter(otp_app, enqueuer) do
    otp_app
    |> get(enqueuer, [])
    |> Keyword.fetch!(:adapter)
  end
end
