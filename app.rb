require './config'

require 'sinatra/base'
require 'sinatra/reloader'

module AllMusicDown
  class Application < Sinatra::Base
    helpers Sinatra::ContentFor
    register Kaminari::Helpers::SinatraHelpers

    configure :development do
      register Sinatra::Reloader
    end

    configure do
      set :port, ENV['PORT']
    end

    get '/' do
      @entries = Entry.all.page(params[:page]).per(params[:per_page])
      slim :index
    end

    get '/entries' do
      Entry.all.page(params[:page]).per(params[:per_page]).to_json
    end

  end
end
