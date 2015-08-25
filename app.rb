require './config'

require 'sinatra/base'
require 'sinatra/reloader'

module AllMusicDown
  class Application < Sinatra::Base
    helpers Sinatra::ContentFor

    configure :development do
      register Sinatra::Reloader
    end

    configure do
      set :port, ENV['PORT']
      set :views, settings.root + '/dist'
      set :public_folder, 'dist'
    end

    get '/' do
      # @entries = Entry.all.page(params[:page]).per(params[:per_page])
      send_file File.join(settings.public_folder, 'index.html')
    end

    get '/entries' do
      Entry.all.page(params[:page]).per(params[:per_page]).to_json
    end

  end
end
