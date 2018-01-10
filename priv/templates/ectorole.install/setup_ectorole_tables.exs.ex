defmodule EctoRole.Repo.Migrations.SetupEctoRoleTables do
  use Ecto.Migration

  def change do
    create table(:entity) do
      add :name, :string, null: false
      add :value, :string, null: false
      add :key, :string, null: false

    end
    create index(:entity, [:key])


    create table(:permission) do
      add :name, :string, null: false
      add :read, :string, null: false
      add :write, :string, null: false
      add :create, :boolean, null: false
      add :delete, :boolean, null: false
      add :key, :string, null: false

      timestamps
    end

    create index(:permission, [:key])


    create table(:role) do
      add :name, :string, null: false
      add :value, :string, null: false
      add :key, :string, null: false

    end
    create index(:role, [:key])

    create table(:schema) do
      add :name, :string, null: false
      add :fields, :string, null: false

      timestamps
    end



  end
end