module Respect
  module Rails
    # The implementation is strongly inspired from
    # ActionDispatch::Routing::RoutesInspector.
    class Info

      def initialize
        @engines = []
        @engines_by_name = {}
        @app = ApplicationInfo.new(::Rails.application)
        @app.routes = collect_routes(::Rails.application.routes.routes)
        @engines << @app
        # Engines were collected while collecting routes, so now we sort them.
        # They won't be touched again.
        @engines.sort!
      end

      attr_reader :engines
      attr_reader :engines_by_name
      attr_reader :app

      def routes
        @app.routes
      end

      private

      def collect_routes(routes, mounted_point = nil)
        result = []
        routes.each do |route|
          route = RouteInfo.new(route, mounted_point)
          next if route.internal?
          if route.engine?
            result += collect_engine_routes(route)
          else
            result << route
          end
        end
        result.sort!
      end

      def collect_engine_routes(route)
        return unless route.engine?
        engine_info = EngineInfo.new(route.endpoint)
        return if @engines_by_name[engine_info.name]

        routes = route.rack_app.routes
        if routes.is_a?(ActionDispatch::Routing::RouteSet)
          engine_info.routes = collect_routes(routes.routes, route)
          @engines << engine_info
          @engines_by_name[engine_info.name] = engine_info
          engine_info.routes
        else
          []
        end
      end

    end # class Info
  end # module Rails
end # module Respect