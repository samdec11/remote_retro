defmodule RemoteRetro.RetroChannel do
  @moduledoc """
  Implement our Retro channel.
  """

  use RemoteRetro.Web, :channel
  alias RemoteRetro.{Presence, PresenceUtils, Idea, Emails, Mailer, Retro}

  def join("retro:" <> retro_id, _, socket) do
    query = from idea in Idea, where: idea.retro_id == ^retro_id
    existing_ideas = Repo.all(query)
    socket_ideas = Phoenix.Socket.assign(socket, :ideas, existing_ideas)
    socket_retro = Phoenix.Socket.assign(socket_ideas, :retro_id, retro_id)

    send self(), :after_join
    {:ok, socket_retro}
  end

  def handle_info(:after_join, socket) do
    {:ok, user} = Phoenix.Token.verify(socket, "user", socket.assigns.user_token)
    user_stamped = Map.put(user, :online_at, :os.system_time(:milli_seconds))
    Presence.track(socket, socket.assigns.user_token, user_stamped)

    push socket, "presence_state", Presence.list(socket)
    push socket, "existing_ideas", %{"ideas" => socket.assigns.ideas}
    {:noreply, socket}
  end

  def handle_in("proceed_to_next_stage", %{"stage" => "action-item-distribution"}, socket) do
    email_send_status = Emails.action_items_email(socket.assigns.retro_id)
                        |> Mailer.deliver_now

    push socket, "email_send_status", %{"success" => !!email_send_status}
    {:noreply, socket}
  end

  def handle_in("proceed_to_next_stage", %{"stage" => stage}, socket) do
    retro = Repo.get(Retro, socket.assigns.retro_id)
    retro = Ecto.Changeset.change retro, stage: stage
    case Repo.update retro do
      {:ok, _struct} ->
        broadcast! socket, "proceed_to_next_stage", %{"stage" => stage}
        {:noreply, socket}
      {:error, _changeset} -> IO.puts "everything is broken!!"
    end
  end


  def handle_in("new_idea", %{"body" => body, "category" => category, "author" => author}, socket) do
    changeset = Idea.changeset(%Idea{body: body, category: category, retro_id: socket.assigns.retro_id, author: author})
    idea = Repo.insert!(changeset)

    broadcast! socket, "new_idea_received", idea
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

  def handle_in("idea_live_edit", %{"id" => id, "liveEditText" => live_edit_text}, socket) do
    broadcast! socket, "idea_live_edit", %{"id" => id, "liveEditText" => live_edit_text}
    {:noreply, socket}
  end

  def handle_in("idea_edited", %{"id" => id, "body" => body}, socket) do
    idea = Repo.get(Idea, id)
    idea = Ecto.Changeset.change(idea, body: body)
    idea = Repo.update!(idea)

    broadcast! socket, "idea_edited", idea
    {:noreply, socket}
  end

  def handle_in("delete_idea", id, socket) do
    idea = RemoteRetro.Repo.delete!(%Idea{id: id})

    broadcast! socket, "idea_deleted", idea
    {:noreply, socket}
  end

  intercept ["presence_diff"]
  def handle_out("presence_diff", _msg, socket) do
    presences = Presence.list(socket)
    new_state = PresenceUtils.give_facilitator_role_to_longest_tenured(presences)

    push socket, "presence_state", new_state
    {:noreply, socket}
  end
end
