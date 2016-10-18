module ZeroDowntimeMigrations
  module DSL
    attr_accessor :data, :ddl, :index, :migrating, :safe

    def data?
      !!@data
    end

    def ddl?
      !!@ddl
    end

    def index?
      !!@index
    end

    def migrating?
      !!@migrating
    end

    def mixed?
      [data?, ddl?, index?].select(&:itself).size > 1
    end

    def safe?
      !!@safe || ENV["SAFETY_ASSURED"].presence
    end

    def unsafe?
      !safe?
    end
  end
end
