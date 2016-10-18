module ZeroDowntimeMigrations
  module Migration
    extend DSL

    def self.prepended(mod)
      mod.singleton_class.prepend(DSL)
    end

    def ddl_disabled?
      !!disable_ddl_transaction
    end

    def define(*)
      Migration.migrating = true
      Migration.safe = true
      super
    end

    def migrate(direction)
      @direction = direction

      Migration.data = false
      Migration.ddl = false
      Migration.index = false
      Migration.migrating = true
      Migration.safe ||= reverse_migration? || rollup_migration?

      super.tap do
        validate(:ddl_migration)
        validate(:mixed_migration)
        Migration.migrating = false
        Migration.safe = false
      end
    end

    private

    def ddl_method?(method)
      %i(
        add_belongs_to
        add_column
        add_foreign_key
        add_reference
        add_timestamps
        change_column
        change_column_default
        change_column_null
        change_table
        create_join_table
        create_table
        drop_join_table
        drop_table
        remove_belongs_to
        remove_column
        remove_columns
        remove_foreign_key
        remove_index
        remove_index!
        remove_reference
        remove_timestamps
        rename_column
        rename_column_indexes
        rename_index
        rename_table
        rename_table_indexes
      ).include?(method)
    end

    def index_method?(method)
      %i(add_index).include?(method)
    end

    def method_missing(method, *args)
      Migration.ddl = true if ddl_method?(method)
      Migration.index = true if index_method?(method)
      validate(method, *args)
      super
    end

    def reverse_migration?
      @direction == :down
    end

    def rollup_migration?
      self.class.name == "RollupMigrations"
    end

    def safety_assured
      safe = Migration.safe
      Migration.safe = true
      yield
    ensure
      Migration.safe = safe
    end

    def validate(type, *args)
      Validation.validate!(type, self, *args) if Migration.unsafe?
    end
  end
end
