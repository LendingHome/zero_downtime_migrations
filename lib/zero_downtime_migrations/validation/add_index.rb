module ZeroDowntimeMigrations
  class Validation
    class AddIndex < Validation
      def validate!
        return if concurrent? && migration.ddl_disabled?
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Adding a non-concurrent index is unsafe!

          This action can lock your database table while indexing existing data!

          Instead, let's add the index concurrently in its own migration with
          the DDL transaction disabled.

          This allows PostgreSQL to build the index without locking in a way
          that prevent concurrent inserts, updates, or deletes on the table.
          Standard indexes lock out writes (but not reads) on the table.

            class Index#{table_title}On#{column_title} < ActiveRecord::Migration
              disable_ddl_transaction!

              def change
                add_index :#{table}, #{column.inspect}, algorithm: :concurrently
              end
            end

          If you're 100% positive that this migration is already safe, then wrap the
          call to `add_index` in a `disable_safety_checks!` block.

            class Index#{table_title}On#{column_title} < ActiveRecord::Migration
              def change
                disable_safety_checks! { add_index :#{table}, #{column.inspect} }
              end
            end
        MESSAGE
      end

      def concurrent?
        options[:algorithm] == :concurrently
      end

      def column
        args[1]
      end

      def column_title
        Array(column).map(&:to_s).join("_and_").camelize
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
