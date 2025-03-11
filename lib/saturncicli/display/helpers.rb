require "date"

module SaturnCICLI
  module Display
    module Helpers
      DEFAULT_TRUNCATION_THRESHOLD = 20

      def self.truncate(text)
        return text if text.length <= DEFAULT_TRUNCATION_THRESHOLD
        "#{text[0..DEFAULT_TRUNCATION_THRESHOLD].strip}..."
      end

      def self.truncated_hash(hash)
        hash[0..7]
      end

      def self.squish(text)
        text.gsub(/\s+/, " ").strip
      end

      def self.formatted_datetime(value)
        DateTime.parse(value).strftime("%Y-%m-%d %H:%M:%S")
      rescue Date::Error
        raise "Invalid date format: \"#{value}\""
      end
    end
  end
end
