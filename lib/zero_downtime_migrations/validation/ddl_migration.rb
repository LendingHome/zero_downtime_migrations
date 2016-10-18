module ZeroDowntimeMigrations
  class Validation
    class DdlMigration < Validation
      def validate!
        return unless migration.ddl_disabled? && !Migration.index?
        message = "Disabling the DDL transaction is unsafe!"
        error!(message, correction)
      end

      private

      def correction
        <<-MESSAGE.strip_heredoc
          The DDL transaction should only be disabled for migrations that add indexes.

          Any other data or schema changes must live in their own migration files with
          the DDL transaction enabled just in case they need to be rolled back.
        MESSAGE
      end
    end
  end
end
