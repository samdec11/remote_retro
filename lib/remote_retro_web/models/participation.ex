defmodule RemoteRetroWeb.Participation do
  use RemoteRetroWeb.Web, :model

  schema "participations" do
    belongs_to :user, RemoteRetroWeb.User
    belongs_to :retro, RemoteRetroWeb.Retro, type: Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @required_fields [:user_id, :retro_id]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
