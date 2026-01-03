defmodule LlmLab.Repo.Migrations.CreatePrompts do
  use Ecto.Migration

  def change do
    create table(:prompts) do
      add :title, :string, null: false
      add :content, :text, null: false
      add :category_id, references(:categories, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:prompts, [:category_id])
  end
end
