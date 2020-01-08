require 'sinatra/base'
require 'require_all'

require_all 'app/models'

class ErrorsController < Sinatra::Base
  set :views, Proc.new { File.join(root, '../views/layouts') }

  configure do
    set :start_time, Time.now
  end

  before do
    last_modified settings.start_time
    etag settings.start_time.to_s
    cache_control
  end

  get '/500' do
    etag '500'
    status 500
    haml :'../errors/internal_server_error'
  end

  get '/422' do
    @error_type = params[:error_type]
    @param_key = params[:param_key]
    @type = params[:param_type]
    @value = params[:param_value]
    @path = params[:path]
    params.except!(:error_type, :param_key, :param_type, :param_value, :path)

    @list =
      case @param_key
      when 'campus'
        Campus.all
      when 'type'
        MenuTypes.non_custom
      else
        [ 'error' ]
      end

    etag '422'
    status 422
    haml :"../errors/#{@error_type}"
  end

  not_found do
    etag '404'
    status 404
    haml :'../errors/not_found'
  end
end
