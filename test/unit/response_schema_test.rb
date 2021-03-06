require "test_helper"

class ResponseSchemaTest < Test::Unit::TestCase
  def setup
    @rs = Respect::Rails::ResponseSchema.new
  end

  def test_define_with_block
    s = Respect::HashSchema.define do |s|
      s.integer "result"
    end
    block_def = Proc.new do |r|
      r.body do |s|
        s.integer "result"
      end
    end
    rs = Respect::Rails::ResponseSchema.define(:ok, &block_def)
    assert_equal :ok, rs.status
    assert_equal s, rs.body

    rs = Respect::Rails::ResponseSchema.define(&block_def)
    assert_equal :ok, rs.status
    assert_equal s, rs.body
  end

  def test_duplicata_are_equal
    s = Respect::Rails::ResponseSchema.new(:ok)
    assert_equal s, s.dup
  end

  def test_differs_from_status
    s1 = Respect::Rails::ResponseSchema.new(:ok)
    s2 = Respect::Rails::ResponseSchema.new(:created)
    assert(s1 != s2)
  end

  def test_differs_from_body
    s1 = Respect::Rails::ResponseSchema.new
    s1.body = Respect::IntegerSchema.new
    s2 = Respect::Rails::ResponseSchema.new
    s2.body = Respect::StringSchema.new
    assert(s1 != s2)
  end

  def test_define_from_file
    # Prepare mock file name and contents
    filename = "/path/to/definition_file.rb"
    file_content = <<-EOS.strip_heredoc
      body do |s|
        s.integer "result"
      end
      EOS
    File.stubs(:read).with(filename).returns(file_content)
    # Compute the expected response schema.
    expected_response_schema = Respect::Rails::ResponseSchema.new
    expected_response_schema.body = Respect::HashSchema.define do |s|
      s.integer "result"
    end
    # Do the test.
    rs = Respect::Rails::ResponseSchema.from_file(:ok, filename)
    assert_equal expected_response_schema, rs
  end

  def test_validate_raise_response_validation_error_on_validation_error
    response = mock()
    headers = mock()
    response.stubs(:headers).returns(headers)
    headers_schema = Respect::HashSchema.new
    @rs.stubs(:headers).returns(headers_schema)
    headers_schema.stubs(:validate).with(headers).once

    body = mock()
    response.stubs(:body).returns(body)
    body_schema = Respect::HashSchema.new
    @rs.stubs(:body).returns(body_schema)
    decoded_body = mock()
    ActiveSupport::JSON.stubs(:decode).with(body).returns(decoded_body).once
    body_schema.stubs(:validate).with(decoded_body).raises(Respect::ValidationError.new("message"))
    assert_raises(Respect::Rails::ResponseValidationError) do
      @rs.validate(response)
    end
  end

  def test_validate_returns_true_on_success
    response = mock()
    headers = mock()
    response.stubs(:headers).returns(headers)
    headers_schema = Respect::HashSchema.new
    @rs.stubs(:headers).returns(headers_schema)
    headers_schema.stubs(:validate).with(headers).once
    body = mock()
    response.stubs(:body).returns(body)
    body_schema = Respect::HashSchema.new
    @rs.stubs(:body).returns(body_schema)
    decoded_body = mock()
    ActiveSupport::JSON.stubs(:decode).with(body).returns(decoded_body).once
    body_schema.stubs(:validate).with(decoded_body).once
    assert_equal true, @rs.validate(response)
  end

  def test_validate_query_returns_true_when_no_error
    doc = {}
    @rs.stubs(:validate).with(doc).returns(nil)
    assert_equal true, @rs.validate?(doc)
  end

  def test_validate_query_returns_false_on_error_and_store_last_error
    doc = {}
    error = Respect::Rails::ResponseValidationError.new(Respect::ValidationError.new("message"), :body, {})
    @rs.stubs(:validate).with(doc).raises(error).once
    assert_equal false, @rs.validate?(doc)
    assert_equal error, @rs.last_error
  end

  def test_symbolize_http_status
    assert_equal :ok, Respect::Rails::ResponseSchema.symbolize_http_status(200)
    assert_equal :internal_server_error, Respect::Rails::ResponseSchema.symbolize_http_status(0)
    assert_equal :gateway_timeout, Respect::Rails::ResponseSchema.symbolize_http_status(504)
    assert_equal :http_version_not_supported, Respect::Rails::ResponseSchema.symbolize_http_status(505)
  end

  def test_validate_raise_response_validation_error_for_headers_error
    response = mock()
    headers = mock()
    response.stubs(:headers).returns(headers)
    headers_schema = Respect::HashSchema.new
    @rs.stubs(:headers).returns(headers_schema)
    headers_schema.stubs(:validate).with(headers).raises(Respect::ValidationError.new("message")).once
    simplified_headers = {}
    @rs.stubs(:simplify_headers).with(headers).returns(simplified_headers).once

    body = mock()
    response.stubs(:body).returns(body)
    body_schema = Respect::HashSchema.new
    @rs.stubs(:body).returns(body_schema)
    decoded_body = mock()
    ActiveSupport::JSON.stubs(:decode).with(body).returns(decoded_body)
    body_schema.stubs(:validate).with(decoded_body)
    begin
      @rs.validate(response)
      assert false
    rescue Respect::Rails::ResponseValidationError => e
      assert_equal "headers", e.part
      assert_equal simplified_headers.object_id, e.object.object_id
    end
  end
end
