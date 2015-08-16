require 'sinatra/base'
require './config'

# require_relative './lib/alljp_crawler'

module AlljpDown
  class Application < Sinatra::Base

    configure do
      set :port, ENV['PORT']
    end

    get '/' do
      @entries = Entry.all.page(params[:page]).per(params[:per_page])
      slim :index
    end

  end
end
