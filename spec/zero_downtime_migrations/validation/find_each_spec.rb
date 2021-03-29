RSpec.describe ZeroDowntimeMigrations::Validation::FindEach do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  context "with data migrations using each" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          User.all.each
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "with data migrations using each within disable_safety_checks!" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          disable_safety_checks! do
            User.all.each
          end
        end
      end
    end

    it "does not raise an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "with data migrations using find_each" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          User.all.find_each
        end
      end
    end

    it "does not raise an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "outside of a migration" do
    it "does not raise an unsafe migration error" do
      expect { User.all.each }.not_to raise_error(error)
    end
  end
end
