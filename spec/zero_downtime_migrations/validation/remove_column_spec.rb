RSpec.describe ZeroDowntimeMigrations::Validation::RemoveColumn do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  context "when the column droped is in a foreign_key constraint" do
    before do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          create_table(:orders) do |t|
            t.references :user, foreign_key: true
          end
        end
      end.migrate(:up)
    end

    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          remove_column(:orders, :user_id)
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "when the column droped is not in a foreign_key constraint" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          create_table(:orders) do |t|
            t.references :user
          end
          remove_column(:orders, :user_id)
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to_not raise_error
    end
  end
end
