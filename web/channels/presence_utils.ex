defmodule RemoteRetro.PresenceUtils do
  @moduledoc """
  Helpers for retro user presence.
  """
  alias RemoteRetro.Presence
  alias Phoenix.Token

  def track_timestamped(%{assigns: assigns} = socket) do
    {:ok, token_user} = Token.verify(socket, "user", assigns.user_token)
    user = Map.put(token_user, :online_at, :os.system_time)
    Presence.track(socket, assigns.user_token, user)
  end
end
