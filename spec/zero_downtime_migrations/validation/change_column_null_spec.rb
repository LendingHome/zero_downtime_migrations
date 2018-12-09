RSpec.describe ZeroDowntimeMigrations::Validation::ChangeColumnNull do
  let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

  context "with a true null" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column_null :users, :email, true
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "with a false null" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column_null :users, :email, false
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "with a true null has default" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column_null :users, :email, true, ''
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "with a false null has default" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column_null :users, :email, false, ''
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end

  context "without a null" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column :users, :email, :text
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "with a default" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column :users, :email, :text, default: ''
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "with a true null" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column :users, :email, :text, null: true
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "with a true null and has default" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column :users, :email, :text, null: true, default: ''
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "with a false null" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column :users, :email, :text, null: false
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.not_to raise_error(error)
    end
  end

  context "with a false null and has default" do
    let(:migration) do
      Class.new(ActiveRecord::Migration[5.0]) do
        def change
          change_column :users, :email, :text, null: false, default: ''
        end
      end
    end

    it "raises an unsafe migration error" do
      expect { migration.migrate(:up) }.to raise_error(error)
    end
  end
end
