module ZeroDowntimeMigrations
  class Validation
    class DropTable < Validation
      def validate!
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Dropping tables is unsafe!

          This action can cause outages in production if old code is still referencing
          the associated model.

          Instead, remove the dependant code first and add this migration in a seperate PR.

          If you're 100% positive that this migration is already safe, then wrap the
          call to `drop_table` in a `safety_assured` block.

            class Drop#{table_title} < ActiveRecord::Migration
              def change
                safety_assured { drop_table :#{table} }
              end
            end
        MESSAGE
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
