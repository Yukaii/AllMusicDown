$: << File.join(File.dirname(__FILE__), "lib")

require 'sinatra'
require './config'

get '/' do
  'hello world'
end
