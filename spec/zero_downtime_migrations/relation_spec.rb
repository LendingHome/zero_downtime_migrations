RSpec.describe ZeroDowntimeMigrations::Relation do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  before(:all) do
    class User < ActiveRecord::Base
    end
  end

  after(:all) { Object.send(:remove_const, :User) }

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

  context "with data migrations using each within safety_assured" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          safety_assured do
            User.all.each
          end
        end
      end
    end

    it "raises an unsafe migration error" do
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
