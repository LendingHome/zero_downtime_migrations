RSpec.describe ZeroDowntimeMigrations::Validation::RenameColumn do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  context "with a migration that adds a column and index" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          rename_column :users, :active, :is_active
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end
end
