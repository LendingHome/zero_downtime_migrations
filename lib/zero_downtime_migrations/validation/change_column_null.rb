module ZeroDowntimeMigrations
  class Validation
    class ChangeColumnNull < Validation
      def validate!
        null = args[2]
        default = args[3]
        return if null || default.nil?
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Changing a column with a false null and default value is unsafe!

          This action lead to slow database, If table size is big. 

          If you're 100% positive that this migration is safe, then wrap the
          call to `change_column_null` in a `safety_assured` block.

            class Change#{column_title}To#{table_title} < ActiveRecord::Migration
              def change
                safety_assured { change_column_null :#{table}, :#{column}, #{column_null}, default: #{column_default} }
              end
            end

          or `change_column`, if you use `change_column`

            class Change#{column_title}To#{table_title} < ActiveRecord::Migration
              def change
                safety_assured { change_column :#{table}, :#{column}, :column_type, #{column_null}, default: #{column_default} }
              end
            end

        MESSAGE
      end

      def column
        args[1]
      end

      def column_default
        args[3].inspect
      end

      def column_null
        args[2].inspect
      end

      def column_title
        column.to_s.camelize
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
