class RollupMigrations < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.timestamps null: false
    end

    add_index :posts, :title
  end
end
