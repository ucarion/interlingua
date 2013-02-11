$:.unshift File.expand_path('..\..\lib', __FILE__)
require "bundler/setup"
require "interlingua"
require "test/unit"

class Interlingua::TestCase < Test::Unit::TestCase

end