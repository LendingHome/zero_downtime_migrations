RSpec.describe ZeroDowntimeMigrations do
  describe "#initialize" do
    it "loads the db schema and migrations without errors" do
      expect(ActiveRecord::Base.connection.tables.size).to be > 1
    end
  end

  describe "#gemspec" do
    it "returns a gemspec object" do
      expect(described_class.gemspec).to be_a(Gem::Specification)
    end
  end

  describe "#root" do
    it "returns a pathname object" do
      expect(described_class.root).to be_a(Pathname)
    end
  end

  describe "#version" do
    it "returns a version string" do
      expect(described_class.version).to match(/^\d+\.\d+\.\d+$/)
    end
  end
end
