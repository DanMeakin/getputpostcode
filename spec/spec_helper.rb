require 'sinatra'
require 'rack/test'
require_relative '../app.rb'
require_relative '../models.rb'

# Setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |config| 
  config.before(:each) { DataMapper.auto_migrate! }
  config.include RSpecMixin 
end
