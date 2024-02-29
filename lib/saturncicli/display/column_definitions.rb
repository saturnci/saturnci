module SaturnCICLI
  module Display
    class ColumnDefinitions
      include Enumerable

      class << self
        attr_accessor :column_definitions
      end

      def self.define_columns(&block)
        self.column_definitions = block.call
      end

      def each(&block)
        self.class.column_definitions.each(&block)
      end
    end
  end
end
