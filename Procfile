web: bundle exec rackup config.ru -s thin -p $PORT
worker: bundle exec sidekiq -v -c 10 -r ./app.rb
clock:  bundle exec clockwork config/clock.rb
