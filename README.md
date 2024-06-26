# Envy

**Envy** loads and sets environment variables from YAML. It supports all YAML data types, including arrays and hashes.

*Envy* uses the YAML key mapping of a value as the environment variable name. For example, the following YAML configuration...

```yaml
---
app:
  database:
    host: localhost
    port: 4321
  server:
    hosts:
      - localhost
      - grottopress.localhost
    port: 8080
  webhooks:
    - url: "https://example.com"
      token: "a1b2c2"
    - url: "https://myapp.net"
      token: "d4e5f6"
```

...sets environment variables as follows:

```ruby
ENV["APP_DATABASE_HOST"] = "localhost"
ENV["APP_DATABASE_PORT"] = "4321"

ENV["APP_SERVER_HOSTS_0"] = "localhost"
ENV["APP_SERVER_HOSTS_1"] = "grottopress.localhost"
ENV["APP_SERVER_PORT"] = "8080"

ENV["APP_WEBHOOKS_0_URL"] = "https://example.com"
ENV["APP_WEBHOOKS_0_TOKEN"] = "a1b2c2"
ENV["APP_WEBHOOKS_1_URL"] = "https://myapp.net"
ENV["APP_WEBHOOKS_1_TOKEN"] = "d4e5f6"
```

*Envy* loads environment variables only once per application life-cycle. This avoids the overhead of reading and parsing YAML files on every single request.

It sets file permission (`0600` by default) for all config files.

*Envy* supports loading a file from a supplied list of files in decreasing order of priority; the first readable file is loaded.

## Installation

Install the gem and add to the application's Gemfile by executing:

```
bundle add envy --git=https://github.com/GrottoPress/envy.rb
```

If bundler is not being used to manage dependencies, install the gem by executing:

```
# Clone repository
git clone https://github.com/GrottoPress/envy.rb.git ./envy

# Change to the envy directory
cd ./envy

# Build gem
gem build envy.gemspec -o envy.gem

# Install gem
gem install envy.gem
```

## Usage

- Load the first readable file from a supplied list of files. Optionally set files permissions. This does *not* overwrite existing environment variables:

    ```ruby
    require "envy"

    Envy.from_file ".env.yml", ".env.dev.yml", perm: 0o400
    ```

 - Load the first readable file from a supplied list of files. Optionally set files permissions. This *overwrites* existing environment variables:

    ```ruby
    require "envy"

    Envy.from_file! ".env.yml", ".env.dev.yml", perm: 0o400
    ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. [Fork it](https://github.com/GrottoPress/envy.rb/fork)
1. Switch to the `master` branch: `git checkout master`
1. Create your feature branch: `git checkout -b my-new-feature`
1. Make your changes, updating changelog and documentation as appropriate.
1. Commit your changes: `git commit`
1. Push to the branch: `git push origin my-new-feature`
1. Submit a new *Pull Request* against the `GrottoPress:master` branch.
