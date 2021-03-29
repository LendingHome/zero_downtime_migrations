class SafeAddIndexWithDsl < ActiveRecord::Migration[5.0]
  disable_safety_checks!

  def change
    add_index :posts, :created_at
  end
end
