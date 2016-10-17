RSpec.describe ZeroDowntimeMigrations::AddIndex do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  context "with ddl transaction enabled" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          add_index :users, :updated_at
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "without using the concurrently algorithm" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        disable_ddl_transaction!

        def change
          add_index :users, :updated_at
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with the correct options" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        disable_ddl_transaction!

        def change
          add_index :users, :updated_at, algorithm: :concurrently
        end
      end
    end

    it "does not raise an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end
end
