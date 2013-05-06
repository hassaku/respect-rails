module Respect
  module Rails
    class RequestSchema

      class << self
        def define(*args, &block)
          RequestDef.eval(*args, &block)
        end
      end

      def initialize(controller, action)
        @controller = controller
        @action = action
        @default_path_parameters = ObjectSchema.define do |s|
          s.string "controller", equal_to: @controller.to_s, doc: false
          s.string "action", equal_to: @action.to_s, doc: false
        end
        @path_parameters = @default_path_parameters.dup
        @body_parameters = ObjectSchema.new
        @query_parameters = ObjectSchema.new
      end

      attr_reader :controller, :action

      attr_reader :body_parameters, :query_parameters

      attr_reader :path_parameters, :default_path_parameters

      # Merge +path_parameters+ with {#default_path_parameters} and store it.
      def path_parameters=(path_parameters)
        @path_parameters = @default_path_parameters.merge(path_parameters)
        @path_parameters.options[:strict] = false
        @path_parameters
      end

      def body_parameters=(body_parameters)
        @body_parameters = body_parameters
        @body_parameters.options[:strict] = false
        @body_parameters
      end

      def query_parameters=(query_parameters)
        @query_parameters = query_parameters
        @query_parameters.options[:strict] = false
        @query_parameters
      end

      # Validate the given +request+.
      # Raise a {RequestValidationError} if an error occur.
      # Returns +true+ on success.
      def validate(request)
        begin
          path_parameters.validate(request.params)
        rescue Respect::ValidationError => e
          raise RequestValidationError.new(e, :path)
        end
        begin
          query_parameters.validate(request.params)
        rescue Respect::ValidationError => e
          raise RequestValidationError.new(e, :query)
        end
        begin
          body_parameters.validate(request.params)
        rescue Respect::ValidationError => e
          raise RequestValidationError.new(e, :body)
        end
        true
      end

      def validate?(request)
        begin
          validate(request)
          true
        rescue RequestValidationError => e
          @last_error = e
          false
        end
      end

      # Return the last validation error that happens during the
      # validation process. (set by {#validate?})
      # Reset each time {#validate?} is called.
      attr_reader :last_error

      def validate!(request)
        valid = validate?(request)
        if valid
          path_parameters.sanitize_doc!(request.params)
          path_parameters.sanitize_doc!(request.path_parameters)
          query_parameters.sanitize_doc!(request.params)
          query_parameters.sanitize_doc!(request.query_parameters)
          body_parameters.sanitize_doc!(request.params)
          body_parameters.sanitize_doc!(request.body_parameters)
        end
        valid
      end

    end
  end
end
