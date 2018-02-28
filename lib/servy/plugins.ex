defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv

  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env != :test do
      Logger.warn "Warning: #{path} is on the loose!"
      Servy.FourOhFourCounter.bump_count(path)
    end
    conv
  end

  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{ path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%Conv{ path: "/bears?id=" <> id} = conv) do
    %{ conv | path: "/bears/#{id}"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect conv
    end
    conv
  end
end