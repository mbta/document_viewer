defmodule DocumentViewerWeb.UserActionLogger do
  @moduledoc """
  Helper for logging ever action a user takes.
  """

  require Logger

  @spec log(String.t(), atom()) :: :ok
  @spec log(String.t(), atom(), map()) :: :ok
  def log(username, action, params \\ %{}),
    do: Logger.info("User action: username=#{username} action=#{action}#{params_string(params)}")

  @spec params_string(map()) :: String.t()
  defp params_string(params) do
    Enum.reduce(
      params,
      "",
      fn {key, val}, acc ->
        "#{acc} #{key}=#{val}"
      end
    )
  end
end
