web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec sidekiq -e production -C config/sidekiq.yml
rpush: bundle exec rpush start -e $RACK_ENV -f
