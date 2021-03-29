RSpec.describe "deprecations" do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  describe "safety_assured" do
    context "when used inline with a block" do
      let(:migration) do
        Class.new(ActiveRecord::Migration[5.0]) do
          def change
            safety_assured do
              add_index :users, :updated_at
            end
          end
        end
      end

      it "does not raise an unsafe migration error" do
        expect { migration.migrate(:up) }.to_not raise_error(error)
      end

      it "issues a deprecation warning" do
        expect { migration.migrate(:up) }.to output(/deprecated/).to_stderr
      end
    end

    context "when used for the whole migration" do
      let(:migration) do
        Class.new(ActiveRecord::Migration[5.0]) do
          safety_assured

          def change
            add_index :users, :updated_at
          end
        end
      end

      it "does not raise an unsafe migration error" do
        expect { migration.migrate(:up) }.to_not raise_error(error)
      end

      it "issues a deprecation warning" do
        expect { migration.migrate(:up) }.to output(/deprecated/).to_stderr
      end
    end

    context "when set via SAFETY_ASSURED environment variable" do
      let(:migration) do
        Class.new(ActiveRecord::Migration[5.0]) do
          def change
            ENV["SAFETY_ASSURED"] = "1"
            add_index :users, :updated_at
            ENV.delete("SAFETY_ASSURED")
          end
        end
      end

      it "does not raise an unsafe migration error" do
        expect { migration.migrate(:up) }.to_not raise_error(error)
      end

      it "issues a deprecation warning" do
        expect { migration.migrate(:up) }.to output(/deprecated/).to_stderr
      end
    end
  end
end
