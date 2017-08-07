defmodule RemoteRetroWeb.PageView do
  use RemoteRetroWeb.Web, :view

  def include_backdrop, do: true

  def include_js do
    false
  end
end
