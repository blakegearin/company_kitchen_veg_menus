# frozen_string_literal: true

require 'haml'
require 'sinatra/base'

class ApplicationController < Sinatra::Base
  set :public_folder, 'public'
  set :views, Proc.new { File.join(root, '../views/layouts') }

  configure do
    set :start_time, Time.now
  end

  before do
    last_modified settings.start_time
    etag settings.start_time.to_s
    cache_control
  end

  get '/' do
    redirect to('/menu_builder')
  end

  get '/menu_builder' do
    etag 'index'
    haml :'../pages/menu_builder'
  end

  get '/how-it-works' do
    etag 'how-it-works'
    haml :'../pages/how_it_works'
  end

  get '/about' do
    etag 'about'
    haml :'../pages/about'
  end

  get '/public/*' do |sub_path|
    File.read(File.join(settings.public_folder, sub_path))
  end
end
