RSpec.describe ZeroDowntimeMigrations::Migration do
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

    context "with ZERO_DOWNTIME_MIGRATIONS_LAST_UNSAFE_VERSION set" do
      around(:each) do |example|
        ENV["ZERO_DOWNTIME_MIGRATIONS_LAST_UNSAFE_VERSION"] = "20130101000000"
        example.run
        ENV.delete("ZERO_DOWNTIME_MIGRATIONS_LAST_UNSAFE_VERSION")
      end

      it "raises an unsafe migration error when version > ZERO_DOWNTIME_MIGRATIONS_LAST_UNSAFE_VERSION" do
        expect_any_instance_of(migration).to receive(:version).at_least(:once).and_return(20130101000001)
        expect { migration.migrate(:up) }.to raise_error(error)
      end

      it "doesn't raise an unsafe migration error when version == ZERO_DOWNTIME_MIGRATIONS_LAST_UNSAFE_VERSION" do
        expect_any_instance_of(migration).to receive(:version).at_least(:once).and_return(20130101000000)
        expect { migration.migrate(:up) }.to_not raise_error(error)
      end

      it "doesn't raise an unsafe migration error when version < ZERO_DOWNTIME_MIGRATIONS_LAST_UNSAFE_VERSION" do
        expect_any_instance_of(migration).to receive(:version).at_least(:once).and_return(20121231235959)
        expect { migration.migrate(:up) }.to_not raise_error(error)
      end
    end
  end
end
