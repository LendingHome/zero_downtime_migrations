module ZeroDowntimeMigrations
  class Validation
    class RenameColumn < Validation
      def validate!
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Renaming columns is unsafe!

          This action can will make existing running code brake which depend on the column.

          Instead, let's add a new column and add a callback to keep the new_name_for_column updated:

            class AddNewNameForColumnToPosts < ActiveRecord::Migration
              def change
                add_column :post, :new_name_for_column, :boolean
              end
            end

            class Post
              before_save :update_new_column

              private

              def update_new_column
                self.new_name_for_column = old_name_for_column
              end
            end

          Then in a separate deploy we copy over the data in a migration.  The old code, which is using the old column name,
          will still be running even after this migration is finished.  Don't worry though, that is why we added a callback to the old code!
          Here we also make the rest of the code changes to use the `new_name_for_column` and add `old_name_for_column` to ignored_columns:

            class MigratePostsNewNameForColumnData < ActiveRecord::Migration
              def up
                say_with_time "Backport posts.new_name_for_column" do
                  Post.unscoped.select(:id).find_in_batches.with_index do |batch, index|
                    say("Processing batch \#{index}\\r", true)
                    Post.unscoped.where(id: batch).update_all("'new_name_for_column' = 'old_name_for_column'")
                  end
                end
              end
            end

            class Post
              # remove the `before_save :update_new_column` callback
              self.ignored_columns = %i[old_name_for_column]
            end

          Finally once the ignored_columns deploy is live you can:

            class RemoveOldNameForColumnFromPosts < ActiveRecord::Migration[5.0]
              def change
                remove_column :posts, :old_name_for_column
              end
            end

          and remove `old_name_for_column` from the `ignored_columns` in the model.

          If you're 100% positive that this migration is already safe, then wrap the
          call to `rename_column` in a `safety_assured` block.

            class RenameNewNameForColumnForPosts < ActiveRecord::Migration
              def change
                safety_assured { rename_column :posts, :old_name_for_column, :new_name_for_column }
              end
            end
        MESSAGE
      end
    end
  end
end
