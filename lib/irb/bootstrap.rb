require 'rubygems'
require 'yaml'
require 'fileutils'
require 'uri'
require 'citizn'
# require 'require_all'

# common
require './test/test_helper'

################################
# DEBUGGING
################################
puts "citizn"

@template = {test_suite: { citizn_gem: { your: "mom", is: "so", fat: "!", other: "other stuff"}}}

@passport = Citizn::Passport.new(@template)

@identity = @passport.get_identity

puts @identity.inspect
