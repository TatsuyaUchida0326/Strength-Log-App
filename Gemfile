source "https://rubygems.org"

ruby "3.0.6"
gem "rails", "~> 7.1.0"
gem "sprockets-rails"
gem "sqlite3", "~> 1.4"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'rails-i18n'
gem 'faker'
gem 'bootstrap-sass'
gem "bootsnap", require: false
gem 'dotenv-rails', groups: [:development, :test]

group :development, :test do
  gem "debug", platforms: %i[ mri mswin mswin64 mingw x64_mingw ]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

group :production do
  gem 'pg', '0.20.0'
end