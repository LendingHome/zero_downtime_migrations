class CreateTableComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.references :user, null: false, index: true
      t.references :post, null: false, index: true
      t.text :body, null: false
      t.timestamps null: false
    end
  end
end
