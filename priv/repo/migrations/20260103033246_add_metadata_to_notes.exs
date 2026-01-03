defmodule LlmLab.Repo.Migrations.AddMetadataToNotes do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      add :author, :string
      add :models_tested, :string
      add :reference_url, :string
    end
  end
end
