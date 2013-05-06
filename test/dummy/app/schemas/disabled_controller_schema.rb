class DisabledControllerSchema < Respect::Rails::ActionSchema
  def basic
    request do |r|
      r.request_parameters do |s|
        s.integer "param1", equal_to: 42
      end
    end
    response_for do |status|
      status.ok do |r|
        r.body root: false do |s|
          s.object do |s|
            s.integer "id", equal_to: 42
          end
        end
      end
    end
  end
end
