class SafeAddIndexWithEnv < ActiveRecord::Migration[5.0]
  def change
    ENV["DISABLE_SAFETY_CHECKS"] = "1"
    add_index :users, :created_at
    ENV.delete("DISABLE_SAFETY_CHECKS")
  end
end
