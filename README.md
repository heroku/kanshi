# 監視

## Purpose

Kanshi watches your Postgres database and reports metrics to the log
stream. You can then drain this log to an application (or provide your
own reporter class) to send these metrics to a service, like Librato or
Splunk.

## Installation

Kanshi will work as a gem or as a standalone app.

### Add to existing app on Heroku

1. Add Kanshi to your Gemfile:

           gem 'kanshi', :require => false

2. Add Kanshi to your Procfile:

           kanshi: bundle exec kanshi

3. Run `bundle install`, commit, and deploy.
4. `heroku scale kanshi=1`

### Create as separate Heroku app

1. Push the code as-is to a new Heroku app.
2. Set environment variables with database URLs.
3. `heroku scale kanshi=1`

### Custom install

You can create your own version of `bin/kanshi` to run Kanshi in any way
of your choosing, e.g. monitor specific databases or provide your own
reporter for output. An easy way to do this would be to create a Rake
task to run Kanshi.

## Configuration

If using the `kanshi` binary, configuration is optional but is done
through environment variables:

* Kanshi will monitor all `postgres://` URLs in your environment.
* `KANSHI_SAMPLE_DELAY` will change how often Kanshi monitors your
  database in seconds. Default: 300
* `KANSHI_PREFIX` will change the prefix used on metrics. Default:
  `kanshi`

Environment variables have no effect on the Kanshi library code, so if
executing Kanshi manually, configuration is done via the options hash
passed to `Kanshi.run`:

* `:databases`: A hash of database names to URLs ({String => String})
* `:delay`: The delay between samples (Fixnum). Default: 300.
* `:reporter`: A Class that responds to `#report` to recieve metrics
  (Class). Default: `Kanshi::ScrollsReporter`.

## Name

Kanshi (監視) is Japanese for _surveillance_.
