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
          Let's use the `find_each` method to fetch records in batches instead.

          Otherwise we may accidentally load tens or hundreds of thousands of
          records into memory all at the same time!

          If you're 100% positive that this migration is already safe, then wrap the
          call to `each` in a `safety_assured` block.

            class YourMigration < ActiveRecord::Migration
              def change
                safety_assured do
                  # use .each in this block
                end
              end
            end
        MESSAGE
      end
    end
  end
end
