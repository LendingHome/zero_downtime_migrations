module ZeroDowntimeMigrations
  class Error < StandardError
  end

  class UndefinedValidationError < Error
  end

  class UnsafeMigrationError < Error
    def initialize(error, correction)
      error_with_type = "#{self.class.name}: #{error}"
      super("#{error_with_type}\n\n#{correction}")
    end
  end
end
