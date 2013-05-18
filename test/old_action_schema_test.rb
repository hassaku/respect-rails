require 'test_helper'

class OldActionSchemaTest < ActiveSupport::TestCase

  test "url_for is working" do
    s = Respect::Rails::OldActionSchema.from_controller(:automatic_validation, :basic_get)
    assert_equal("http://my_application.org/automatic_validation/basic_get.json",
      s.url_for)
  end

  test "have working _url helper" do
    s = Respect::Rails::OldActionSchema.from_controller(:automatic_validation, :basic_get)
    assert_equal("http://my_application.org/automatic_validation/basic_get.json",
      s.automatic_validation_basic_get_url(format: "json"))
  end

  test "have working _path helper" do
    s = Respect::Rails::OldActionSchema.from_controller(:automatic_validation, :basic_get)
    assert_equal("/automatic_validation/basic_get.json",
      s.automatic_validation_basic_get_path(format: "json"))
  end

  test "have other schema helper" do
    s = Respect::Rails::OldActionSchema.from_controller(:automatic_validation, :basic_get)
    assert_equal("http://my_application.org/no_schema/basic.json",
      s.no_schema_basic_url(format: "json"))
  end

  test "has_schema" do
    assert(!Respect::Rails::OldActionSchema.from_controller(:automatic_validation, :no_schema_at_all).has_schema?)
    assert(Respect::Rails::OldActionSchema.from_controller(:automatic_validation, :response_schema_from_file).has_schema?)
    assert(Respect::Rails::OldActionSchema.from_controller(:automatic_validation, :response_schema_from_file_unknown_status).has_schema?)
  end
end
