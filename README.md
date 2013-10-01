# Request

A simple http/net wrapper to make http request easy.

Inspired by request.js

## Installation

Add this line to your application's Gemfile:

    gem 'request'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install request

## Usage

> How to fork it?

```ruby
Request["https://api.github.com/repo/v2e4lisp/request/forks"].auth("user", "pass").post
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
