module ZeroDowntimeMigrations
  class Validation
    class RemoveColumn < Validation
      def validate!
        error!(message) if postgresql? && exists_in_constraint?
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          It looks like #{column} is in a foreign_key constraint.  Be aware that removing a foreign_key takes an `AccessExclusiveLock`
          on both tables (i.e. also on the one being refered to).  This will lock your queries to both tables.

          If you're 100% positive that this migration is already safe, then wrap the
          call to `remove_column` in a `safety_assured` block.
        MESSAGE
      end

      def postgresql?
        connection.class == ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
      end

      def column
        args[1]
      end

      def table
        args[0]
      end

      def exists_in_constraint?
        connection.select_value(
          <<~SQL
            SELECT 1 AS one
            FROM pg_constraint c
              JOIN LATERAL UNNEST(c.conkey) WITH ORDINALITY AS u(attnum, attposition) ON TRUE
              JOIN pg_class tbl ON tbl.oid = c.conrelid
              JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
              JOIN pg_attribute col ON (col.attrelid = tbl.oid AND col.attnum = u.attnum)
              WHERE c.contype = 'f' AND col.attname = '#{column}' AND tbl.relname = '#{table}'
                AND sch.nspname = '#{connection.current_schema}'
              LIMIT 1
          SQL
        ) == 1
      end

      def connection
        ActiveRecord::Base.connection
      end
    end
  end
end
