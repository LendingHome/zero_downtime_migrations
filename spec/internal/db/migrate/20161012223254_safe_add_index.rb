class SafeAddIndex < ActiveRecord::Migration[5.0]
  def change
    safety_assured { add_index :posts, :published }
  end
end
