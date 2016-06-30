defmodule ElixirStream.User do
  use ElixirStream.Web, :model
  alias ElixirStream.Repo

  schema "users" do
    field :username, :string
    field :password_digest, :string
    field :email, :string
    field :password, :string, virtual: true
    has_many :entries, Entry
    timestamps
  end

  @required_fields ~w(username email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid chageset is returned
  with no validation performed.
  """

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> validate_length(:username, min: 5)
    |> validate_length(:username, max: 50)
    |> validate_length(:password, min: 8)
    |> validate_length(:password, max: 100)
    |> unique_constraint(:email, on: Repo)
    |> unique_constraint(:username, on: Repo)
  end


  def set_password_digest(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(
          changeset, :password_digest, Bcrypt.hashpwsalt(password)
        )
      _ ->
        changeset
      end
  end
end
