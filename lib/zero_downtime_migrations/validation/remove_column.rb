module ZeroDowntimeMigrations
  class Validation
    class RemoveColumn < Validation
      def validate!
        return if valid_type?
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Removing a column is not reversible unless you provide a type
          on the column.
          
          In order to make this migration reversible, add a third argument 
          to the remove_column method which corresponds to the type of 
          the column.

          For example, if this column is a boolean, then let's add :boolean
          as remove_column's third argument.

            class Remove#{column_title}From#{table_title} < ActiveRecord::Migration
              def change
                remove_column :#{table}, :#{column}, :boolean
              end
            end

          This gem only checks for database-agnostic types listed in the 
          Rails documentation: 
          https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column

          If you are using a database-specific type in your columns 
          (such as "polygon" in MySQL or "jsonb" in PostgreSQL), then this
          migration will still be reversible provided that you include the
          correct type as the third argument of remove_column.

          If you're 100% positive that this migration is already safe, then wrap the
          call to `remove_column` in a `safety_assured` block.

            class Remove#{column_title}From#{table_title} < ActiveRecord::Migration
              def change
                safety_assured { add_column :#{table}, :#{column}, :#{column_type || default_type} }
              end
            end
        MESSAGE
      end

      def column
        args[1]
      end

      def column_title
        column.to_s.camelize
      end

      def column_type
        args[2]
      end

      def default_type
        :boolean
      end

      def table
        args[0]
      end

      def table_title
        table.to_s.camelize
      end
    end
  end
end
