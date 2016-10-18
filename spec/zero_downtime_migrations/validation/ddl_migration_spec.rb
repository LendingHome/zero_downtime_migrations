RSpec.describe ZeroDowntimeMigrations::Validation::DdlMigration do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  context "with a migration that adds a column with ddl disabled" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        disable_ddl_transaction!

        def change
          add_column :users, :active, :boolean
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with a migration that queries data with ddl disabled" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        disable_ddl_transaction!

        def change
          User.find_in_batches
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with a migration that updates data with ddl disabled" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        disable_ddl_transaction!

        def change
          add_column :users, :active, :boolean
          User.update_all(active: true)
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with a migration that creates data with ddl disabled" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        disable_ddl_transaction!

        def change
          User.new(email: "test").save!
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end
end
