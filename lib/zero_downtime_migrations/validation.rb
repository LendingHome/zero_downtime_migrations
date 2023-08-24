module ZeroDowntimeMigrations
  class Validation
    def self.validate!(type, *args, **hargs)
      return unless Migration.migrating? && Migration.unsafe?

      begin
        validator = type.to_s.classify
        const_get(validator).new(Migration.current, *args, **hargs).validate!
      rescue NameError
        raise UndefinedValidationError.new(validator)
      end
    end

    attr_reader :migration, :args, :hargs

    def initialize(migration, *args, **hargs)
      @migration = migration
      @args = args
      @hargs = hargs
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
      args.last.is_a?(Hash) ? args.last : hargs
    end

    def validate!
      raise NotImplementedError
    end
  end
end
