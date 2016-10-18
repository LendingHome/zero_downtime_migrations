module ZeroDowntimeMigrations
  class Validation
    class MixedMigration < Validation
      def validate!
        return unless Migration.mixed?
        message = "Mixing data/index/schema changes in the same migration is unsafe!"
        error!(message, correction)
      end

      private

      def correction
        <<-MESSAGE.strip_heredoc
          Instead, let's split apart these types of migrations into separate files.

          * Introduce schema changes with methods like `create_table` or `add_column` in one file.
          * Update data with methods like `update_all` or `save` in another file.
          * Add indexes concurrently within their own file as well.
        MESSAGE
      end
    end
  end
end
