defmodule SimpliGov do
  @moduledoc """
  API client for authorizing and making requests against the SimpliGov API.
  """
  require Logger

  alias OAuth2.Client
  alias SimpliGov.Workflow
  alias SimpliGov.Workflow.FileMetadata

  @page_size 50
  @api_headers [{"Cache-Control", "no-cache"}]

  @spec client(String.t()) :: Client.t()
  def client(site) do
    client_args = [
      strategy: OAuth2.Strategy.ClientCredentials,
      client_id: System.get_env("SIMPLI_GOV_API_CLIENT_ID"),
      client_secret: System.get_env("SIMPLI_GOV_API_CLIENT_SECRET"),
      site: site,
      token_url: "/auth/identity/connect/token"
    ]

    params = [
      auth_scheme: "request_body",
      username: System.get_env("SIMPLI_GOV_API_USERNAME"),
      password: System.get_env("SIMPLI_GOV_API_PASSWORD"),
      grant_type: "password",
      redirect_uri: "tapredirect",
      scope: "api"
    ]

    client_args
    |> Client.new()
    |> Client.put_serializer("application/json", Jason)
    |> Client.get_token!(params)
  end

  @spec workflows(Client.t()) :: [Workflow.t()]
  def workflows(client), do: workflows_by_page([], client)

  @spec file(Client.t(), FileMetadata.t()) :: binary()
  def file(client, %FileMetadata{id: id}) do
    path = "/api/v1/files/#{id}"

    {:ok, %OAuth2.Response{body: file}} =
      OAuth2.Client.get(client, full_url(client, path), @api_headers)

    file
  end

  @spec workflows_by_page([Workflow.t()], Client.t()) :: [Workflow.t()]
  @spec workflows_by_page([Workflow.t()], Client.t(), integer()) :: [Workflow.t()]
  defp workflows_by_page(acc, client, page_count \\ 1) do
    path = "/api/v1/workflows"

    filters = [
      # Only pull documents attached to Youth Pass applications
      "WorkflowTemplateName eq 'Youth Pass'",
      # Wait for a period to give the "push" functionality a chance to copy the file over to S3
      "WorkflowInstanceCreated lt #{ten_minutes_ago_string()}"
    ]

    opts = [
      params: %{
        "\$top" => @page_size,
        "\$skip" => (page_count - 1) * @page_size,
        "\$orderby" => "WorkflowInstanceUpdated desc, WorkflowInstanceCreated desc",
        "\$count" => true,
        "\$filter" => Enum.join(filters, " and ")
      }
    ]

    case OAuth2.Client.get(client, full_url(client, path), @api_headers, opts) do
      {:ok, %OAuth2.Response{body: %{"Items" => []}}} ->
        acc

      {:ok, %OAuth2.Response{body: %{"Items" => items}}} ->
        new_workflows = Enum.map(items, &Workflow.from_json/1)

        workflows_by_page(acc ++ new_workflows, client, page_count + 1)

      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.warn("SimpliGov API request error: #{reason}")
        workflows_by_page(acc, client, page_count)
    end
  end

  @spec full_url(Client.t(), String.t()) :: String.t()
  defp full_url(client, path), do: "#{client.site}#{path}"

  # Returns a date-time for ten minutes ago, truncated to the nearest second,
  # and formatted using ISO 8601.
  @spec ten_minutes_ago_string() :: String.t()
  defp ten_minutes_ago_string do
    "Etc/UTC"
    |> DateTime.now!()
    |> DateTime.add(-600, :second)
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
  end
end
