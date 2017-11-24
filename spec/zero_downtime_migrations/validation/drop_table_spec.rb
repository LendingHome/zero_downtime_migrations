RSpec.describe ZeroDowntimeMigrations::Validation::DropTable do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  let(:migration) do
    Class.new(ActiveRecord::Migration[5.0]) do
      def change
        drop_table :users
      end
    end
  end

  it "raises an unsafe migration error" do
    expect { migration.migrate(:up) }.to raise_error(error)
  end

  context "when within safety_assured" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          safety_assured do
            drop_table :users
          end
        end
      end
    end

    it "does not raise an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end
end
