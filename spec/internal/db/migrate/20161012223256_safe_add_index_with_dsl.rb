class SafeAddIndexWithDsl < ActiveRecord::Migration[5.0]
  safety_assured

  def change
    add_index :posts, :created_at
  end
end
