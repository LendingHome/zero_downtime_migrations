class SafeAddIndexWithEnv < ActiveRecord::Migration[5.0]
  def change
    ENV["SAFETY_ASSURED"] = "1"
    add_index :users, :created_at
    ENV.delete("SAFETY_ASSURED")
  end
end
