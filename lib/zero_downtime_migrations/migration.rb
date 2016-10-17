module ZeroDowntimeMigrations
  module Migration
    def ddl_disabled?
      !!disable_ddl_transaction
    end

    def migrate(direction)
      @direction = direction
      super
    end

    private

    def loading_schema?
      is_a?(ActiveRecord::Schema)
    end

    def method_missing(method, *args)
      unless loading_schema? || reverse_migration? || rollup_migration? || safe?
        validator = "#{namespace}::#{method.to_s.classify}".safe_constantize
        validator.new(self, args).validate! if validator
      end

      super
    end

    def namespace
      Module.nesting.last
    end

    def reverse_migration?
      @direction == :down
    end

    def rollup_migration?
      self.class.name == "RollupMigrations"
    end

    def safety_assured
      safe = @safe
      @safe = true
      yield
    ensure
      @safe = safe
    end

    def safe?
      !!(@safe || ENV["SAFE_MIGRATION"].presence)
    end
  end
end
