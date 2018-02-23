defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
 
  test "can connect to http server" do
    spawn(HttpServer, :start, [9876])
    someHostInNet = 'localhost'
    {:ok, sock} = :gen_tcp.connect(someHostInNet, 9876, 
                                    [:binary, packet: :raw, active: false])
    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """                        
    :ok = :gen_tcp.send(sock, request)
    {:ok, response} = :gen_tcp.recv(sock, 0)
    
    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Length: 377\r
    Content-Type: text/html\r
    \r
    <h1>All The Bears!</h1>

    <ul>

        <li>Brutus - Grizzly</li>

        <li>Iceman - Polar</li>

        <li>Kenai - Grizzly</li>

        <li>Paddington - Brown</li>

        <li>Roscoe - Panda</li>

        <li>Rosie - Black</li>

        <li>Scarface - Grizzly</li>

        <li>Smokey - Black</li>

        <li>Snow - Polar</li>

        <li>Teddy - Brown</li>

    </ul>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
    :ok = :gen_tcp.close(sock)
   
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end

end