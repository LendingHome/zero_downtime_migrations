module ZeroDowntimeMigrations
  class Validation
    attr_reader :migration, :args

    def initialize(migration, args)
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
