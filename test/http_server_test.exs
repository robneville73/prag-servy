defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
 
  test "can connect to http server" do
    spawn(HttpServer, :start, [9876])
    host = "http://localhost:9876/"

    [
      "#{host}wildthings", 
      "#{host}bears", 
      "#{host}bears/1", 
      "#{host}wildlife",
      "#{host}api/bears"
    ]  
    |> Enum.map(fn url -> 
        Task.async(HTTPoison, :get, [url]) 
        end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_successful_response/1)

  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
  end

end