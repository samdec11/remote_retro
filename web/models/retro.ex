defmodule RemoteRetro.Retro do
  @moduledoc false
  use RemoteRetro.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "retros" do
    field :stage, :string, read_after_writes: true
    timestamps()
  end
end
