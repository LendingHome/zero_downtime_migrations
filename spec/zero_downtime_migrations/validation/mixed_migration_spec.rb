RSpec.describe ZeroDowntimeMigrations::Validation::MixedMigration do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  context "with a migration that adds a column and index" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          add_column :users, :active, :boolean
          add_index :users, :active
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with a migration that adds a column and queries data" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          add_column :users, :active, :boolean
          User.find_in_batches
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with a migration that adds a column and updates data" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
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

  context "with a migration that adds an index and updates data" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          User.where(email: nil).delete_all
          add_index :users, :created_at
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with a migration that adds a column and creates data" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          add_column :users, :active, :boolean
          User.new(email: "test").save!
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end
end
