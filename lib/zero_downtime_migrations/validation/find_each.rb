module ZeroDowntimeMigrations
  class Validation
    class FindEach < Validation
      def validate!
        message = "Using `ActiveRecord::Relation#each` is unsafe!"
        error!(message, correction)
      end

      private

      def correction
        <<-MESSAGE.strip_heredoc
          Instead, let's use the `find_each` method to fetch records in batches.

          Otherwise we may accidentally load tens or hundreds of thousands of
          records into memory all at the same time!
        MESSAGE
      end
    end
  end
end
