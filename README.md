[![Build Status](https://travis-ci.org/knoopx/action_dispatch-routing-i18n.svg?branch=master)](https://travis-ci.org/knoopx/action_dispatch-routing-i18n)

# ActionDispatch::Routing::I18n

Minimalist I18n for Rails routes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_dispatch-routing-i18n', github: "knoopx/action_dispatch-routing-i18n"
```

And then execute:

    $ bundle

## Usage

```ruby
scope(locale: "es") do
  resources :users # defines users_es_path
end

users_path # fallbacks to users_#{I18n.locale}_path
```

## Contributing

1. Fork it ( https://github.com/knoopx/action_dispatch-routing-i18n/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
