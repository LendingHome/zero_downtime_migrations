class CreateTableComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.references :user, null: false
      t.references :post, null: false
      t.text :body, null: false
      t.timestamps null: false
    end
  end
end
