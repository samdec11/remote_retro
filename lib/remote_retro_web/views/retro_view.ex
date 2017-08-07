defmodule RemoteRetroWeb.RetroView do
  use RemoteRetroWeb.Web, :view

  def include_backdrop, do: false

  def include_js do
    true
  end
end
