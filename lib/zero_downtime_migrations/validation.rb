module ZeroDowntimeMigrations
  class Validation
    def self.validate!(type, migration, *args)
      validator = type.to_s.classify
      validator = const_get(validator) if const_defined?(validator)
      validator.new(migration, *args).validate! if validator
    end

    attr_reader :migration, :args

    def initialize(migration, *args)
      @migration = migration
      @args = args
    end

    def error!(*args)
      raise UnsafeMigrationError.new(*args)
    end

    def options
      args.last.is_a?(Hash) ? args.last : {}
    end

    def validate!
      raise NotImplementedError
    end
  end
end
