module ZeroDowntimeMigrations
  class Validation
    class ChangeColumn < Validation
      def validate!
        return unless options.key?(:null)
        return if options[:null] || options[:default].nil?
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Changing a column with a false null and default value is unsafe!

          This action lead to slow database, If table size is big.

          If you're 100% positive that this migration is safe, then wrap the
          call to `change_column` in a `safety_assured` block.

            class Change#{column_title}To#{table_title} < ActiveRecord::Migration
              def change
                safety_assured { change_column :#{table}, :#{column}, :#{column_type}, #{column_options} }
              end
            end

        MESSAGE
      end

      def column
        args[1]
      end

      def column_options
        options.map { |k, v| "#{k}: #{v.inspect}" }.join ', '
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

      def table_title
        table.to_s.camelize
      end
    end
  end
end
