ruby-bgs
========

`bgs` is a gem that helps developers within the VA connect to a set of
VA internal webservices, the `BGS` (Benefits Gateway Services).


Example Usage
-------------

```ruby
require 'bgs'

bgs = BGS::Services.new(
    env: "something",
    client_ip: "127.0.0.1",
    client_station_id: "999999",
    client_username: "paultag",
    application: "APPNAME",
)
puts bgs.people.find_by_ssn "9999999999"
```


Testing
-------

You'll need Ruby 2.2.4 if you don't have it.

> $ rbenv install 2.2.4

Install dependencies

> $ gem install bundler --no-rdoc --no-ri
> $ bundle install

Run tests

> $ bundle exec rake spec


License
=======

[The project is in the public domain](LICENSE.md), and all contributions will also be released in the public domain. By submitting a pull request, you are agreeing to waive all rights to your contribution under the terms of the [CC0 Public Domain Dedication](http://creativecommons.org/publicdomain/zero/1.0/).

This project constitutes an original work of the United States Government.
