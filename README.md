bgs
===

Example Usage
-------------

```ruby
require 'bgs'

s = BGS::PersonWebService.new(
    env: "something",
    client_ip: "127.0.0.1",
    client_station_id: "999999",
    client_username: "paultag",
    application: "APPNAME",
)
puts s.find_by_ssn "9999999999"
```

License
=======

[The project is in the public domain](LICENSE.md), and all contributions will also be released in the public domain. By submitting a pull request, you are agreeing to waive all rights to your contribution under the terms of the [CC0 Public Domain Dedication](http://creativecommons.org/publicdomain/zero/1.0/).

This project constitutes an original work of the United States Government.
