require 'active_support'
require 'active_support/core_ext'
require 'diplomat'
require "citizn/version"
require "citizn/identity"
require "citizn/passport"

module Citizn
  class << self
    attr_accessor :settings
    attr_accessor :env

    def configure(env, settings = {})
      # make sure keys are symbols
      self.settings = (settings.blank?)? settings : settings.deep_symbolize_keys[env]
      self.env = env

      # initialize Diplomat
      unless settings.blank?
        Diplomat.configure do |config|
          config.url = self.settings[:host]
          config.acl_token =  self.settings[:token]
        end
      end

    end

    def convert_hash_to_array_of_hashes(parent,hash)
      array = []
      hash.each do |key, value|
        if value.class == Hash
          array.concat self.convert_hash_to_array_of_hashes("#{parent}/#{key}",value)
        else
          array << {"#{parent}/#{key}" => value.to_s}
        end
      end
      return array
    end
  end
  raise 'Citizn only supports ruby >= 2.0.0' unless RUBY_VERSION.to_f >= 2.0

end
