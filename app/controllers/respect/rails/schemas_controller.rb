module Respect
  module Rails
    # Controller to get all the information relative to the
    # REST API of this application.
    class SchemasController < ApplicationController
      def index
        @info = Respect::Rails::Info.new
        respond_to do |format|
          format.html # index.html.erb
        end
      end
    end
  end # module Rails
end # module Respect
