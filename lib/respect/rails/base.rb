module Respect
  module Rails
    class Base
      include ::Rails.application.routes.url_helpers

      class << self

        def controller_name
          name.sub(/Schema$/, '').underscore
        end

        def from_controller(controller_name, action_name = nil)
          klass = "#{controller_name}_schema".classify.safe_constantize

          return nil unless klass

          if action_name
            klass.new(action_name)
          else
            klass
          end
        end

      end

      def initialize(action_name)
        @controller_name = self.class.controller_name
        @action_name = action_name
        @response_schemas = ResponseSchemaSet.new(controller_name, @action_name)
        send(@action_name) if respond_to?(@action_name)
      end

      attr_reader :controller_name, :action_name

      def define_request(&block)
        @request_schema = RequestSchema.define(controller_name, action_name, &block)
      end

      attr_reader :request_schema

      def response_for(&block)
        block.call(@response_schemas)
        @response_schemas
      end

      attr_reader :response_schemas

      def default_url_options
        {
          controller: @controller_name,
          action: @action_name,
          host: "example.org",
          format: "json",
        }
      end
    end
  end
end