module ZeroDowntimeMigrations
  class Error < StandardError
  end

  class UndefinedValidationError < Error
  end

  class UnsafeMigrationError < Error
  end
end
