module ZeroDowntimeMigrations
  module Migration
    class << self
      attr_accessor :migrating, :safe

      def migrating?
        !!@migrating
      end

      def safe?
        !!@safe || ENV["SAFETY_ASSURED"].presence
      end

      def unsafe?
        !safe?
      end
    end

    def ddl_disabled?
      !!disable_ddl_transaction
    end

    def migrate(direction)
      Migration.migrating = true
      Migration.safe = false
      @direction = direction
      super.tap { Migration.migrating = false }
    end

    private

    delegate :safe?, to: Migration

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
      safe = Migration.safe
      Migration.safe = true
      yield
    ensure
      Migration.safe = safe
    end
  end
end
