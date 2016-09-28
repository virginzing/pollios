# Prerequisite


* Install RVM:

```bash
$ curl -sSL https://get.rvm.io | bash -s stable
```

* Install Ruby via RVM:

```bash
$ rvm install 2.2.2
```

* Install dependency software:

```bash
brew install postgresql
brew install mongodb
brew install redis
brew install memcached
brew install git-flow
```

and install [heroku-toolbelt](https://toolbelt.heroku.com/)

# Install

Clone source code from bitbucket:

```bash
$ git clone https://bitbucket.org/pollios/pollios
$ cd pollios
$ git checkout develop
```

Update your Gemfile:

```bash
$ gem install bundler
$ bundle
```

Update your `db/schema.rb` file to match the stucture of your database:

```bash
$ rake db:create
$ rake db:migrate
```

Start Sidekiq for queuing:

```bash
$ redis-server /usr/local/etc/redis.conf
$ bundle exec sidekiq
```

Start Memcached for caching

```bash
$ memcached -d
```

Run a guard script for testing

```bash
$ bundle exec guard
```

Start server

```bash
$ rails s
```

Go to web browser: `localhost:3000`

Clone data from your backups file(.dump) to local.

```bash
$ pg_restore --verbose --clean --no-acl --no-owner -h localhost -d pollios_development latest.dump
```

# Development

Setup `git-flow` to manage work on git:

```bash
$ git flow init
```

Check out this link for information: [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/)

### Frontend
Install all dependencies
```bash
npm install
```

Run gulp to take care of parsing SCSS and bundle JS
```bash
gulp
```

# Deploy

### Development server on heroku

1) Add the remote to development server on heroku.

```
$ git remote add development git@heroku.com:codeapp-polliosdev.git
```		
2) Push your code to the heroku remote.

```
$ git push development develop:master
```

### Production server on heroku

1) Add the remote to production server on heroku.

```
$ git remote add production git@heroku.com:codeapp-pollios.git
```

2) Push your code to the heroku remote.

```
$ git push production master
```

### Bitbucket

Push your code to the bitbucket remote.

```
$ git push -u bitbucket --all
```

Pull your code from bitbucket.

```
$ git pull origin master
```
