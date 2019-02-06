module ZeroDowntimeMigrations
  class Validation
    class AddForeignKey < Validation
      def validate!
        return unless requires_validate_constraints?
        error!(message) unless foreign_key_not_validated?
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Adding a foreign key causes an `ShareRowExclusiveLock` (or `AccessExclusiveLock` on PostgreSQL before 9.5) on both tables.
          It is possible to add a foreign key in one step and validate later (which only causes RowShareLocks)

            class Add#{foreign_table}ForeignKeyTo#{table} < ActiveRecord::Migration
              def change
                add_foreign_key :#{table}, #{foreign_table}, validate: false
              end
            end

            class Validate#{foreign_table}ForeignKeyOn#{table} < ActiveRecord::Migration
              def change
                validate_foreign_key :#{table}, :#{foreign_table}
              end
            end

          Note, both `add_foreign_key` and `validate_foreign_key` accept `name` and `column` options.
        MESSAGE
      end

      def foreign_key_not_validated?
        options[:validate] == false
      end

      def foreign_table
        args[1]
      end

      def table
        args[0]
      end

      def requires_validate_constraints?
        supports_validate_constraints?
      end

      def supports_validate_constraints?
        ActiveRecord::Base.connection.respond_to?(:supports_validate_constraints?) &&
          ActiveRecord::Base.connection.supports_validate_constraints?
      end
    end
  end
end
