defmodule RemoteRetroWeb.PageController do
  use RemoteRetroWeb.Web, :controller

  def index(conn, _params) do
    current_user = get_session(conn, :current_user)

    conn = assign(conn, :current_user, current_user)
    render conn, "index.html"
  end
end
