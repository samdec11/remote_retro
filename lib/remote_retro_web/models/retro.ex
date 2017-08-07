defmodule RemoteRetroWeb.Retro do
  use RemoteRetroWeb.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Poison.Encoder, except: [:__meta__]}

  schema "retros" do
    has_many :participations, RemoteRetroWeb.Participation
    has_many :ideas, RemoteRetroWeb.Idea
    field :stage, :string, read_after_writes: true

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, %{stage: _stage} = params \\ %{}) do
    struct
    |> cast(params, [:stage])
    |> validate_inclusion(:stage, ["prime-directive", "idea-generation", "action-items", "action-item-distribution"])
  end
end
