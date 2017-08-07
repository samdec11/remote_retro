defmodule RemoteRetroWeb.RetroChannel do
  use RemoteRetroWeb.Web, :channel

  alias RemoteRetroWeb.{Presence, PresenceUtils, Idea, Emails, Mailer, Retro}

  def join("retro:" <> retro_id, _, socket) do
    socket = assign(socket, :retro_id, retro_id)
    retro = Repo.get!(Retro, retro_id) |> Repo.preload(ideas: :user)

    send self(), :after_join
    {:ok, retro, socket}
  end

  def handle_info(:after_join, socket) do
    PresenceUtils.track_timestamped(socket)
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end

  def handle_in("enable_edit_state", %{"id" => id}, socket) do
    broadcast! socket, "enable_edit_state", %{"id" => id}
    {:noreply, socket}
  end

  def handle_in("disable_edit_state", %{"id" => id}, socket) do
    broadcast! socket, "disable_edit_state", %{"id" => id}
    {:noreply, socket}
  end

  def handle_in("user_typing_idea", %{"userToken" => userToken}, socket) do
    broadcast! socket, "user_typing_idea", %{"userToken" => userToken}
    {:noreply, socket}
  end

  def handle_in("idea_live_edit", %{"id" => id, "liveEditText" => live_edit_text}, socket) do
    broadcast! socket, "idea_live_edit", %{"id" => id, "liveEditText" => live_edit_text}
    {:noreply, socket}
  end

  def handle_in("highlight_idea", %{"id" => id, "isHighlighted" => is_highlighted}, socket) do
    broadcast! socket, "idea_highlighted", %{"id" => id, "isHighlighted" => is_highlighted}
    {:noreply, socket}
  end

  def handle_in("new_idea", %{"body" => body, "category" => category, "userId" => user_id}, socket) do
    idea =
      %Idea{
        body: body,
        category: category,
        retro_id: socket.assigns.retro_id,
        user_id: user_id
      }
      |> Idea.changeset
      |> Repo.insert!
      |> Repo.preload(:user)

    broadcast! socket, "new_idea_received", idea
    {:noreply, socket}
  end

  def handle_in("idea_edited", %{"id" => id, "body" => body}, socket) do
    idea =
      Repo.get(Idea, id)
      |> Idea.changeset(%{body: body})
      |> Repo.update!
      |> Repo.preload(:user)

    broadcast! socket, "idea_edited", idea
    {:noreply, socket}
  end

  def handle_in("delete_idea", id, socket) do
    idea = Repo.delete!(%Idea{id: id})

    broadcast! socket, "idea_deleted", idea
    {:noreply, socket}
  end

  def handle_in("proceed_to_next_stage", %{"stage" => "action-item-distribution"}, socket) do
    retro_id = socket.assigns.retro_id
    update_retro!(retro_id, "action-item-distribution")
    Emails.action_items_email(retro_id) |> Mailer.deliver_now

    broadcast! socket, "proceed_to_next_stage", %{"stage" => "action-item-distribution"}
    {:noreply, socket}
  end

  def handle_in("proceed_to_next_stage", %{"stage" => stage}, socket) do
    update_retro!(socket.assigns.retro_id, stage)

    broadcast! socket, "proceed_to_next_stage", %{"stage" => stage}
    {:noreply, socket}
  end

  defp update_retro!(retro_id, stage) do
    Repo.get(Retro, retro_id)
    |> Retro.changeset(%{stage: stage})
    |> Repo.update!
  end
end
