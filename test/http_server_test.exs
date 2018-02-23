defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
 
  test "can connect to http server" do
    spawn(HttpServer, :start, [9876])
    parent = self()

    max_concurrent_requests = 5

    for _ <- 1..max_concurrent_requests do
      spawn(fn -> 
        send(parent, HTTPoison.get "http://localhost:9876/wildthings")  
      end)
    end

    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "Bears, Lions, Tigers"
      end
    end
    
  end

end