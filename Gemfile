# frozen_string_literal: true

source 'https://rubygems.org'

ruby File.read('.ruby-version').strip

gem 'chromedriver-helper'
gem 'haml'
gem 'nokogiri'
gem 'rack'
gem 'redis'
gem 'require_all'
gem 'route_downcaser'
gem 'sass'
gem 'sinatra'
gem 'watir'

group :production do
  gem 'heroku-deflater'
end

group :development, :test do
  gem 'pry'
end
