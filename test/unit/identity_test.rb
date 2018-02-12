require "test_helper"
require 'webmock/minitest'
require "./lib/citizn/identity"

class IdentityTest < Minitest::Test

  def setup
    @host = 'http://test.com'
    @host_kv = {
      test:               "#{@host}/v1/kv/test?recurse",
      test_put:           "#{@host}/v1/kv/test",
      test_put_app_name:  "#{@host}/v1/kv/test/app_name",
      test_delete:        "#{@host}/v1/kv/test/app_name/your" }
    Diplomat.configure do |config|
      config.url = @host
    end
    @identity = Citizn::Identity.new({test: { app_name: :test}})
    WebMock.reset!
    # WebMock.allow_net_connect!
    stub_request(:get, @host_kv[:test])
    .to_return(status: 200, body: "{}", headers: {})
    stub_request(:put, @host_kv[:test_put]).
    to_return(status: 200, body: "{}", headers: {})
    stub_request(:put, @host_kv[:test_put_app_name]).
    to_return(status: 200, body: "{}", headers: {})


  end
  def test_it_raises_error_on_missing_app_name
    identity = Citizn::Identity.new({})
    assert_raises do
      identity.get_identity
    end
  end
  def test_it_requests_identity
    @identity.get_identity
    assert_requested :get, @host_kv[:test], times: 2
  end
  def test_it_handles_404
    stub_request(:any, @host_kv[:test])
    .to_return(status: 404, body: "{}", headers: {})
    @identity.get_identity
    assert_requested :get, @host_kv[:test], times: 2
  end
  def test_it_will_register_missing_keys
    stub_request(:put, @host_kv[:test_put]).
    with(body: {"app_name"=>"test"} ).
    to_return(status: 200, body: "{}", headers: {})

    stub_request(:put, @host_kv[:test_put_app_name]).
    with( body: {"test/app_name"=>"test"}).
    to_return(status: 200, body: "{}", headers: {})

    @identity.get_identity
    assert_requested :get, @host_kv[:test], times: 2
    assert_requested :put, @host_kv[:test_put_app_name]
  end
  def test_it_will_remove_unused_keys
    stub_request(:get, @host_kv[:test])
    .to_return(
      status: 200,
      body: '[{"Key":"test/app_name","Value":"dGVzdA=="},{"Key":"test/app_name/your","Value":"aW52YWxpZCBrZXk="}]',
      headers: {} )

    stub_request(:delete, @host_kv[:test_delete])

    @identity.get_identity
    assert_requested :get, @host_kv[:test], times: 2
    assert_requested :delete, @host_kv[:test_delete]
  end
  def test_it_will_update_keys
    identity = {"test": { "app_name": "new app name"}}

    @identity.update_identity_with(identity)
    assert_requested :put, @host_kv[:test_put_app_name]
  end
end
