module ZeroDowntimeMigrations
  class Validation
    def self.validate!(method, *args)
      return unless Migration.migrating? && Migration.unsafe?

      begin
        validator = method.to_s.classify
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
      error = UnsafeMigrationError
      debug = "#{error}: #{migration_name} is unsafe!"
      message = [message, debug, nil].join("\n")
      raise error.new(message)
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
