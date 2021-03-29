class SafeAddColumnWithDefault < ActiveRecord::Migration[5.0]
  def change
    disable_safety_checks! { add_column :posts, :published, :boolean, default: false }
  end
end
