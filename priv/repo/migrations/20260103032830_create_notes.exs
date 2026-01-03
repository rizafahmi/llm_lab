defmodule LlmLab.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :content, :text, null: false
      add :prompt_id, references(:prompts, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:notes, [:prompt_id])
  end
end
