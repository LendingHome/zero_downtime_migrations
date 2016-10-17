class SafeAddColumnWithDefault < ActiveRecord::Migration[5.0]
  def change
    safety_assured { add_column :posts, :published, :boolean, default: false }
  end
end
