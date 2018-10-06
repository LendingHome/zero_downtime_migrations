RSpec.describe ZeroDowntimeMigrations::Validation::RemoveColumn do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  context "without a type" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          remove_column :users, :active
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with an unsupported or non-agnostic type" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          remove_column :users, :active, :jsonb
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with a valid type" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          remove_column :users, :active, :boolean
        end
      end
    end

    it "does not raise an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end
end
