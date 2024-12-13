source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"
gem "bootsnap", require: false

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development do
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "webmock"

  gem "factory_bot", "6.2.1" # Fixtures replacement
  gem "factory_bot_rails", "6.2.0" # Fixtures replacement
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  # gem "capybara"
  # gem "selenium-webdriver"

  gem 'database_cleaner-active_record'
  # TODO: in case we add redis
  # gem 'database_cleaner-redis'
end
