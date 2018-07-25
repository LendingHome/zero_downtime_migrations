module ZeroDowntimeMigrations
  class Validation
    class AddColumn < Validation
      def validate!
        return if options[:default].nil? # only nil is safe
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Adding a column with a default is unsafe!

          This can take a long time with significant database
          size or traffic and lock your table!

          First let’s add the column without a default. When we add
          a column with a default it has to lock the table while it
          performs an UPDATE for ALL rows to set this new default.

            class Add#{column_title}To#{table_title} < ActiveRecord::Migration
              def change
                add_column :#{table}, :#{column}, :#{column_type}
              end
            end

          Then we’ll set the new column default in a separate migration.
          Note that this does not update any existing data! This only
          sets the default for newly inserted rows going forward.

            class AddDefault#{column_title}To#{table_title} < ActiveRecord::Migration
              def change
                change_column_default :#{table}, :#{column}, #{column_default}
              end
            end

          Finally we’ll backport the default value for existing data in
          batches. This should be done in its own migration as well.
          Updating in batches allows us to lock 1000 rows at a time
          (or whatever batch size we prefer).

            class BackportDefault#{column_title}To#{table_title} < ActiveRecord::Migration
              def change
                #{table_model}.unscoped.select(:id).find_in_batches.with_index do |records, index|
                  puts "Processing batch \#{index + 1}\\r"
                  #{table_model}.unscoped.where(id: records).update_all(#{column}: #{column_default})
                end
              end
            end

          Note that in some cases it may not even be necessary to backport a default value.

            class #{table_model} < ActiveRecord::Base
              def #{column}
                self["#{column}"] ||= #{column_default}
              end
            end

          If you're 100% positive that this migration is already safe, then wrap the
          call to `add_column` in a `safety_assured` block.

            class Add#{column_title}To#{table_title} < ActiveRecord::Migration
              def change
                safety_assured { add_column :#{table}, :#{column}, :#{column_type}, default: #{column_default} }
              end
            end
        MESSAGE
      end

      def column
        args[1]
      end

      def column_default
        options[:default].inspect
      end

      def column_title
        column.to_s.camelize
      end

      def column_type
        args[2]
      end

      def table
        args[0]
      end

      def table_model
        table_title.singularize
      end

      def table_title
        table.to_s.camelize
      end
    end
  end
end
