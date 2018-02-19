defmodule Servy.Handler do
  
  @moduledoc "Handles HTTP requests."  
  
  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  alias Servy.Conv
  alias Servy.BearController

  @doc "Transforms the request into a response."
  def handle(request) do
    request 
    |> parse
    |> rewrite_path
    |> log
    |> route 
    |> track
    |> put_resp_size
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    BearController.delete(conv, id)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    file = 
      @pages_path
      |> Path.join("about.html")
    case File.read(file) do
      {:ok, content}    -> %{ conv | status: 200, resp_body: content}
      {:error, :enoent} -> not_found(conv)
      {:error, reason}  -> server_error(conv, reason)
    end
  end

  def route(%Conv{method: "GET", path: "/pages/faq"} = conv) do
    file = 
      @pages_path
      |> Path.join("faq.md")
    case File.read(file) do
      {:ok, content} ->
        case Earmark.as_html(content) do
          {:ok, html, _list} -> %{ conv | status: 200, resp_body: html}
          {_, _doc, errors}  -> server_error(conv, errors)
        end
      {:error, :enoent} -> not_found(conv)
      {:error, reason}  -> server_error(conv, reason)
    end
  end

  def route(%Conv{method: "GET", path: "/pages/" <> filename} = conv) do
    file =
      @pages_path
      |> Path.join(filename)
    case File.read(file) do
      {:ok, content} -> %{ conv | status: 200, resp_body: content}
      {:error, :enoent} -> not_found(conv)
      {:error, reason}  -> server_error(conv, reason)
    end
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!"}
  end

  def put_resp_content_type(%Conv{} = conv, content_type) do
    resp_headers = Map.update!(conv.resp_headers, 
                               "Content-Type",
                               fn (_x) ->  content_type end)
    %Conv{ conv | resp_headers: resp_headers }
  end

  def put_resp_size(%Conv{} = conv) do
    %{ conv | resp_headers: Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body)) }
  end

  def write_resp_headers(%Conv{ resp_headers: resp_headers}) do
    Enum.map(resp_headers, fn ({header, value}) -> 
        "#{header}: #{value}"
      end
    ) |> Enum.sort |> Enum.join("\r\n") 
  end

  defp not_found(%Conv{} = conv) do
    %{ conv | status: 404, resp_body: "File not found!"}
  end

  defp server_error(%Conv{} = conv, reason) do
    %{ conv | status: 500, resp_body: "File error: #{reason}"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status conv}\r
    #{write_resp_headers(conv)}\r
    \r
    #{conv.resp_body}
    """
  end

end