RSpec.describe ZeroDowntimeMigrations::Validation::AddForeignKey do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  context "when the database supports_validate_constraints" do
    context "adding a foreign key and not specifying validate" do
      let(:migration) do
        Class.new(ActiveRecord::Migration[5.0]) do
          def change
            create_table :order
            add_column :users, :order_id, :integer
            add_foreign_key :users, :order
          end
        end
      end

      it "raises an unsafe migration error" do
        expect { migration.migrate(:up) }.to raise_error(error)
      end
    end

    context "adding a foreign key and specifying validate true" do
      let(:migration) do
        Class.new(ActiveRecord::Migration[5.0]) do
          def change
            create_table :order
            add_column :users, :order_id, :integer
            add_foreign_key :users, :order, validate: true
          end
        end
      end

      it "raises an unsafe migration error" do
        expect { migration.migrate(:up) }.to raise_error(error)
      end
    end

    context "adding a foreign key and specifying validate false" do
      let(:migration) do
        Class.new(ActiveRecord::Migration[5.0]) do
          def change
            create_table :order
            add_column :users, :order_id, :integer
            add_foreign_key :users, :order, validate: false
          end
        end
      end

      it "raises nothing" do
        expect { migration.migrate(:up) }.to_not raise_error
      end
    end
  end

  context "when the database does not supports_validate_constraints" do
    before do
      allow_any_instance_of(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter).to receive(
        :supports_validate_constraints?
      ).and_return(false)
    end

    context "adding a foreign key and not specifying validate" do
      let(:migration) do
        Class.new(ActiveRecord::Migration[5.0]) do
          def change
            create_table :order
            add_column :users, :order_id, :integer
            add_foreign_key :users, :order
          end
        end
      end

      it "raises nothing" do
        expect { migration.migrate(:up) }.to_not raise_error
      end
    end
  end
end
