module ZeroDowntimeMigrations
  class Validation
    class DdlMigration < Validation
      def validate!
        return unless migration.ddl_disabled? && !Migration.index?
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Disabling the DDL transaction is unsafe!

          The DDL transaction should only be disabled for migrations that add indexes.

          Any other data or schema changes must live in their own migration files with
          the DDL transaction enabled just in case they need to be rolled back.

          If you're 100% positive that this migration is already safe, then simply
          add a call to `safety_assured` to your migration.

            class #{migration_name} < ActiveRecord::Migration
              disable_ddl_transaction!
              safety_assured

              def change
                # ...
              end
            end
        MESSAGE
      end
    end
  end
end
