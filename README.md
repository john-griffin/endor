# Endor

The Rails API backend to [CrawlsofLondon.com](http://www.crawlsoflondon.com).
The source code for the web frontend, written in Ember.js can be found
[here](https://github.com/john-griffin/yavin).

## Highlights

* Uses token authentication on top of Devise to authorize requests.
* Active model serializers used to ensure API compatibility with Ember Data.
* Versioned and namespaced API.
* Fully integration tested using Rspec.

## Prerequisites

You will need the following things properly installed on your computer.

* [Ruby](https://www.ruby-lang.org)
* [Bundler](http://bundler.io)
* [Postgres](http://www.postgresql.org)

## Installation

* `git clone <repository-url>` this repository
* change into the new directory
* `bundle install`
* `bundle exec rake db:migrate`

## Running / Development

* `bundle exec rails s -b 0.0.0.0`
* Visit your app at [http://localhost:3000](http://localhost:3000).
* Better yet fire up the Ember frontend (see above) and connect to it.

### Running Tests

* `bundle exec rspec`

### Deploying

Deployed to Heroku using the
[Ruby buildpack](https://github.com/heroku/heroku-buildpack-ruby).
