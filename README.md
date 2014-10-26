Free Library on Rails
=====================

This is an open source web application for organising a
[distributed library](https://en.wikipedia.org/wiki/Distributed_library).


Installation
------------

Here are some basic installation instructions.

0. Make sure you have Ruby 1.9 or higher as well as [Bundler](http://bundler.io/)
   (one way would be to use [RVM](https://rvm.io/rvm/install)).
   - for production: you may want to use [Apache](http://httpd.apache.org/) +
     [mod_passenger](https://www.phusionpassenger.com/).

1. Install dependencies.
   - `sudo apt-get install libxslt1-dev libsqlite3-dev libmysqlclient-dev`
   - `bundle install`

2. `rake secret` --- copy this and place it as your session key secret in config/environment.rb

3. Setup the database
   - for production: in config/database.yml edit the database name, username and password.
   - `rake db:create` (when upgrading use `rake db:migrate`)

API tokens are set in config/application.yml.
You can get an isbnDB api token [here](https://isbndb.com/account/create.html).
There is no guarantee that the API tokens stored in config/application.yml will work for you.

There are other things you can change in config/application.yml (like a tags blacklist if you have problems with swearing or pro-capitalists)


If you have questions about the license please email medwards@walledcity.ca


See also
--------

* Distributed Library on
    [Rabblepedia](http://rabble.ca/toolkit/rabblepedia/distributed-library) and
    [Wikipedia](https://en.wikipedia.org/wiki/Distributed_library)
* [GNU Distributed Library Project](http://www.nongnu.org/dlp/index.html)

