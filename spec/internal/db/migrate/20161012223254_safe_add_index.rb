class SafeAddIndex < ActiveRecord::Migration[5.0]
  def change
    disable_safety_checks! { add_index :posts, :published }
  end
end
