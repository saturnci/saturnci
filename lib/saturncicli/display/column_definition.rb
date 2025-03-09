module SaturnCICLI
  module Display
    class ColumnDefinition
      def self.find(resource_name)
        new(resource_name).column_definition_object
      end

      def initialize(resource_name)
        @resource_name = resource_name
      end

      def column_definition_object
        column_definition_class.new
      end

      private

      def column_definition_class
        require_relative "#{@resource_name}_table_column_definitions"
        Object.const_get(class_name)
      end

      def class_name
        "SaturnCICLI::Display::#{@resource_name.to_s.split('_').map(&:capitalize).join}TableColumnDefinitions"
      end
    end
  end
end
