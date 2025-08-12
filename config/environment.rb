ENV['RAILS_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['RAILS_ENV'])

# Load models and controllers
Dir[File.join(File.dirname(__FILE__), '../models', '*.rb')].each { |file| require file }
require_relative '../app'
