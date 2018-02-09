require 'yaml'
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "citizn"

require "minitest/autorun"

env = :development
config = YAML::load(File.open('config/config.yml'))

Citizn.configure(env, config)
