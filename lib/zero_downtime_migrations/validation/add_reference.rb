module ZeroDowntimeMigrations
  class Validation
    class AddReference < Validation
      def validate!
        return if !migration.index? && migration.safe?
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
        Adding a non-concurrent index is unsafe whilst adding a reference!

        This action can lock your database table while indexing existing data!

        Instead add the index concurrently in its own migration with the DDL
        transaction disabled.
        MESSAGE
      end
    end
  end
end
