source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.4'

gem 'rails', '~> 6.0.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rack-cors'
gem 'faker'
gem 'pgn'
gem 'redis'
gem 'bcrypt'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'stockfish'
gem 'rubocop'

group :development, :test do
  gem 'rspec-rails'
  gem 'simplecov', :require => false
  gem 'pry-rails'
  gem 'brakeman', require: false
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
