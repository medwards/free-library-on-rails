Free Library on Rails
=====================

This is an open source web application for organising a
[distributed library](https://en.wikipedia.org/wiki/Distributed_library).


Installation
------------

Here are some basic installation instructions.

0. Make sure you have Ruby 2.0 or higher as well as [Bundler](http://bundler.io/)
   (one way would be to use [RVM](https://rvm.io/rvm/install)).
   - for production: you may want to use [Apache](http://httpd.apache.org/) +
     [mod_passenger](https://www.phusionpassenger.com/).

1. Install dependencies.
   - `sudo apt-get install libxslt1-dev libsqlite3-dev libmysqlclient-dev`
   - `bundle install`

2. `rake secret` --- copy this and place it as your session key secret in `config/initializers/secret_token.rb`

3. Setup the database
   - for production: in config/database.yml edit the database name, username and password.
   - `rake db:setup` (when upgrading use `rake db:migrate`)

API tokens are set in config/application.yml.
You can get an ISBNdb api token [here](https://isbndb.com/account/create.html).
There is no guarantee that the API tokens stored in config/application.yml will work for you.

There are other things you can change in config/application.yml (like a tags blacklist if you have problems with swearing or pro-capitalists)


If you have questions about the license please email medwards@walledcity.ca


Features
--------

* Members can
  * signup and create an account;
  * add their books and videos;
  * search items by name, author or description;
  * loan items after confirmation from the owner (with return date);
  * leave comments about other members as some form of user feedback.
* Book information by ISBN (from ISBNdb and Google Books).
* Book covers from Google Books.
* Send SMS on loan request (optional).
* Tagging.
* Librarians may edit all books and tags (optional).

### Librarians
In some communities it can be useful to have librarians who help to complete missing
information, correct mistakes and help with tagging. To enable this, you need to make
one user a librarian by running the following command (replacing `admin@example.com`
with the email address of the librarian):

```
echo "User.where(email: 'admin@example.com').update_all(librarian_since: Time.now)" | rails console
```

If you'd like to allow librarians to make other members a librarian, set `use_librarian`
to `delegate` in config/application.yml. Librarians will then see a button on other users'
profile page.


See also
--------

* Distributed Library on
    [Rabblepedia](http://rabble.ca/toolkit/rabblepedia/distributed-library) and
    [Wikipedia](https://en.wikipedia.org/wiki/Distributed_library)
* [GNU Distributed Library Project](http://www.nongnu.org/dlp/index.html)

