module ZeroDowntimeMigrations
  class Validation
    def self.validate!(type, *args)
      return unless Migration.migrating? && Migration.unsafe?

      begin
        validator = type.to_s.classify
        const_get(validator).new(Migration.current, *args).validate!
      rescue NameError
        raise UndefinedValidationError.new(validator)
      end
    end

    attr_reader :migration, :args

    def initialize(migration, *args)
      @migration = migration
      @args = args
    end

    def error!(message)
      raise UnsafeMigrationError.new(message)
    end

    def migration_name
      migration.class.name
    end

    def options
      args.last.is_a?(Hash) ? args.last : {}
    end

    def validate!
      raise NotImplementedError
    end
  end
end
