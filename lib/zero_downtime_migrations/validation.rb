module ZeroDowntimeMigrations
  class Validation
    def self.validate!(type, migration = nil, *args)
      return unless Migration.migrating? && Migration.unsafe?
      validator = type.to_s.classify

      if const_defined?(validator)
        const_get(validator).new(migration, *args).validate!
      else
        raise UndefinedValidationError.new(validator)
      end
    end

    attr_reader :migration, :args

    def initialize(migration, *args)
      @migration = migration
      @args = args
    end

    def error!(*args)
      raise UnsafeMigrationError.new(*args)
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
