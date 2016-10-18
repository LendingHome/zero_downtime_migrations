class AddIndexConcurrently < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :posts, :body, algorithm: :concurrently
  end
end
