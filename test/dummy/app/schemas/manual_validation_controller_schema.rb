class ManualValidationControllerSchema < Respect::Rails::OldActionSchema
  def raise_custom_error
    request do |r|
      r.query_parameters do |s|
        s.integer "param1", equal_to: 42
      end
    end
    response_for do |status|
      status.ok do |r|
        r.body hash: false do |s|
          s.hash do |s|
            s.integer "id", equal_to: 53
          end
        end
      end
    end
  end

  # FIXME(Nicolas Despres): Factor this schema with "raise_custom_error
  def raise_custom_error_without_rescue
    request do |r|
      r.query_parameters do |s|
        s.integer "param1", equal_to: 42
      end
    end
    response_for do |status|
      status.ok do |r|
        r.body do |s|
          s.integer "id", equal_to: 53
        end
      end
    end
  end
end
