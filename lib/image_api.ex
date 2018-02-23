defmodule ImageApi do
  def query(resource) do
    api_url(resource)
    |> HTTPoison.get
    |> handle_response
  end

  defp api_url(resource) do
    "https://api.myjson.com/bins/#{resource}"
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    image_url = 
      body
      |> Poison.Parser.parse!
      |> get_in(["image", "image_url"])
    {:ok, image_url }
  end

  defp handle_response({:ok, %{status_code: _status, body: body}}) do
    message = 
      body
      |> Poison.Parser.parse!
      |> get_in(["message"])
    {:error, message}
  end

  defp handle_response({:error, %{reason: reason}}) do
    {:error, reason}
  end

end