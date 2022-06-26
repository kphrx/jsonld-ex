defmodule JSON.LD.DocumentLoader.DefaultTest do
  use ExUnit.Case, async: false

  setup do
    Tesla.Mock.mock(fn
      %{method: :get, url: "http://jsonld.test/200-context"} ->
        context = %{
          "@context" => %{
            "homepage" => %{"@id" => "http://xmlns.com/foaf/0.1/homepage", "@type" => "@id"},
            "name" => "http://xmlns.com/foaf/0.1/name"
          }
        }

        Tesla.Mock.json(context)

      %{method: :get, url: "http://jsonld.test/302-context"} ->
        %Tesla.Env{status: 302, headers: [{"location", "http://jsonld.test/200-context"}]}

      %{method: :get, url: "http://jsonld.test/referring-other-context"} ->
        context = %{
          "@context" => "http://jsonld.test/200-context"
        }

        Tesla.Mock.json(context)
    end)

    local =
      Jason.decode!("""
        {
          "@context": {
            "name": "http://xmlns.com/foaf/0.1/name",
            "homepage": {"@id": "http://xmlns.com/foaf/0.1/homepage", "@type": "@id"}
          },
          "name": "Manu Sporny",
          "homepage": "http://manu.sporny.org/"
        }
      """)

    {:ok, local: local}
  end

  test "loads remote context (with 200 response code)", %{local: local} do
    remote =
      Jason.decode!("""
        {
          "@context": "http://jsonld.test/200-context",
          "name": "Manu Sporny",
          "homepage": "http://manu.sporny.org/"
        }
      """)

    assert JSON.LD.expand(local) == JSON.LD.expand(remote)
  end

  test "loads remote context (with 302 response code)", %{local: local} do
    remote =
      Jason.decode!("""
        {
          "@context": "http://jsonld.test/302-context",
          "name": "Manu Sporny",
          "homepage": "http://manu.sporny.org/"
        }
      """)

    assert JSON.LD.expand(local) == JSON.LD.expand(remote)
  end

  test "loads remote context referring to other remote contexts", %{local: local} do
    remote =
      Jason.decode!("""
        {
          "@context": "http://jsonld.test/referring-other-context",
          "name": "Manu Sporny",
          "homepage": "http://manu.sporny.org/"
        }
      """)

    assert JSON.LD.expand(local) == JSON.LD.expand(remote)
  end
end
