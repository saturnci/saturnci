module SaturnCICLI
  module CLIHelpers
    DEFAULT_TRUNCATION_THRESHOLD = 40

    def self.truncate(text)
      return text if text.length <= DEFAULT_TRUNCATION_THRESHOLD
      "#{text[0..DEFAULT_TRUNCATION_THRESHOLD].strip}..."
    end

    def self.squish(text)
      text.gsub(/\s+/, " ").strip
    end
  end
end
