class SafeAddIndexWithEnv < ActiveRecord::Migration[5.0]
  def change
    ENV["SAFE_MIGRATION"] = "1"
    add_index :users, :created_at
    ENV.delete("SAFE_MIGRATION")
  end
end
