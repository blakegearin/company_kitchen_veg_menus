require 'sinatra/base'
require 'require_all'

require_all 'app/models'

class CampusesController < Sinatra::Base
  set :views, Proc.new { File.join(root, '../views/layouts') }

  configure do
    set :start_time, Time.now
  end

  before do
    last_modified settings.start_time
    etag settings.start_time.to_s
    cache_control
  end

  get '/campus' do
    redirect to('/')
  end

  get '/campus/:campus' do
    campus_hash = {
      type: 'path',
      key: 'campus',
      value: params[:campus]
    }

    @campus = validate_required_params([campus_hash])[0]
    @campus.downcase!
    @campus =
      if Campus.all_caps.map(&:downcase).include?(@campus)
        @campus.upcase!
      elsif Campus.capitalized.map(&:downcase).include?(@campus)
        @campus.capitalize!
      end

    etag "/campus/#{@campus}"
    haml :'../pages/campus'
  end
end
