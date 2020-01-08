require 'sinatra/base'
require 'require_all'

require_all 'app/models'

class MenuTypesController < Sinatra::Base
  set :views, Proc.new { File.join(root, '../views/layouts') }

  configure do
    set :start_time, Time.now
  end

  before do
    last_modified settings.start_time
    etag settings.start_time.to_s
    cache_control
  end

  get '/type' do
    redirect to('/')
  end

  get '/type/:name' do
    type_hash = {
      type: 'path',
      key: 'type',
      value: params[:name]
    }

    @menu_type = validate_required_params([type_hash])[0]

    etag "/type/#{@menu_type}"
    if ['Custom', 'Full'].include?(@menu_type)
      haml :"../pages/menu_types/#{@menu_type}"
    else
      haml :'../pages/menu_types/filtered'
    end
  end
end
