require './app'
require 'sidekiq/web'

Sidekiq::Web.use Rack::Session::Cookie, :secret => ENV['RACK_SESSION_COOKIE']

# from https://github.com/mperham/sidekiq/issues/2459#issuecomment-125265582
Sidekiq::Web.instance_eval { @middleware.reverse! }

run Rack::URLMap.new({
  '/' => AllMusicDown::Application,
  '/sidekiq' => Sidekiq::Web
})
