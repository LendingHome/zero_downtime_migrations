module ZeroDowntimeMigrations
  class Validation
    class FindEach < Validation
      def validate!
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Using `ActiveRecord::Relation#each` is unsafe!

          Let's use the `find_each` method to fetch records in batches instead.

          Otherwise we may accidentally load tens or hundreds of thousands of
          records into memory all at the same time!

          If you're 100% positive that this migration is already safe, then wrap the
          call to `each` in a `safety_assured` block.

            class #{migration_name} < ActiveRecord::Migration
              def up
                safety_assured do
                  # use ActiveRecord::Relation.each in this block
                end
              end
            end
        MESSAGE
      end
    end
  end
end
