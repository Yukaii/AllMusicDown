require 'sinatra/base'
require './config'

require_relative './lib/alljp_crawler'

module AlljpDown
  class Application < Sinatra::Base

    configure do
      set :port, ENV['PORT']
    end

    get '/' do
      entries = AlljpCrawler.get_entries
      slim :index, locals: {entries: entries}
    end

  end
end
