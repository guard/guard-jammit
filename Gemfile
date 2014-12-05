source 'https://rubygems.org'

gemspec

unless ENV['TRAVIS']
  gem 'redcarpet', require: false
  gem 'yard', require: false
  gem 'pry', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'rubocop', require: false
end

group :development do
  gem 'rake', require: false
  gem 'rspec', require: false
  gem 'guard-compat', require: false
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
  gem 'json'
end
