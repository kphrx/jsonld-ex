defmodule JSON.LD.DocumentLoader.Default do
  @behaviour JSON.LD.DocumentLoader

  alias JSON.LD.DocumentLoader.RemoteDocument
  alias JSON.LD.Options

  @spec load(String.t(), Options.t()) :: {:ok, RemoteDocument.t()} | {:error, any}
  def load(url, _options) do
    with {:ok, res} <- http_get(url) do
      {:ok, %RemoteDocument{document: res.body, document_url: res.url}}
    end
  end

  @content_type ["application/ld+json", "application/json"]

  @spec http_get(String.t()) :: Tesla.Env.result()
  defp http_get(url) do
    client =
      Tesla.client([
        {Tesla.Middleware.Headers, [{"accept", @content_type |> Enum.join(", ")}]},
        {Tesla.Middleware.JSON, decode_content_types: @content_type},
        Tesla.Middleware.FollowRedirects
      ])

    Tesla.get(client, url)
  rescue
    e -> {:error, "Tesla failed: #{inspect(e)}"}
  end
end
