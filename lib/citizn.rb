require 'diplomat'
require "citizn/version"
require "citizn/passport"

module Citizn
  class << self
    attr_accessor :settings
    attr_accessor :env

    def configure(env, settings = nil)
      self.settings = JSON.parse(JSON.dump(settings), symbolize_names: true)[env]
      self.env = env
      unless settings.nil?
        Diplomat.configure do |config|
          config.url = self.settings[:host]
          config.acl_token =  self.settings[:token]
        end
      end
    end

  end
  raise 'Citizn only supports ruby >= 2.0.0' unless RUBY_VERSION.to_f >= 2.0

end
