ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'bundler'

Bundler.require :default, ENV['RACK_ENV'].to_sym

Dotenv.load

Dir.glob("lib/**/*.rb").each {|file| load file }

Mongoid.load!('./config/mongoid.yml')
