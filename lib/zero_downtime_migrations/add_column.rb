module ZeroDowntimeMigrations
  class AddColumn < Validation
    def validate!
      return if options[:default].nil? # only nil is safe
      message = "Adding a column with a default is unsafe!"
      error!(message, correction)
    end

    private

    def correction
      <<-MESSAGE.strip_heredoc
        This action can potentially lock your database table!

        Instead, let's first add the column without a default.

          class Add#{column_title}To#{table_title} < ActiveRecord::Migration
            def change
              add_column :#{table}, :#{column}, :#{column_type}
            end
          end

        Then set the new column default in a separate migration. Note that
        this does not update any existing data.

          class AddDefault#{column_title}To#{table_title} < ActiveRecord::Migration
            def change
              change_column_default :#{table}, :#{column}, #{column_default}
            end
          end

        If necessary then backport the default value for existing data in batches.
        This should be done in its own migration as well.

          class BackportDefault#{column_title}To#{table_title} < ActiveRecord::Migration
            def change
              #{table_model}.select(:id).find_in_batches.with_index do |records, index|
                puts "Processing batch \#{index + 1}\\r"
                #{table_model}.where(id: records).update_all(#{column}: #{column_default})
              end
            end
          end

        Note that in some cases it may not even be necessary to backport a default value.

          class #{table_model} < ActiveRecord::Base
            def #{column}
              self["#{column}"] ||= #{column_default}
            end
          end

        If you're 100% positive that this migration is already safe, then wrap the
        call to `add_column` in a `safety_assured` block.

          class Add#{column_title}To#{table_title} < ActiveRecord::Migration
            def change
              safety_assured { add_column :#{table}, :#{column}, :#{column_type}, default: #{column_default} }
            end
          end
      MESSAGE
    end

    def column
      args[1]
    end

    def column_default
      options[:default].inspect
    end

    def column_title
      column.to_s.camelize
    end

    def column_type
      args[2]
    end

    def table
      args[0]
    end

    def table_model
      table_title.singularize
    end

    def table_title
      table.to_s.camelize
    end
  end
end
