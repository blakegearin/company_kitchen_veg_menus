# frozen_string_literal: true

require 'sinatra/base'
require 'redis'
require 'require_all'

require_all 'app/helpers'
require_all 'app/models'

class MenusController < Sinatra::Base
  set :views, Proc.new { File.join(root, '../views/layouts') }

  configure do
    set :start_time, Time.now
    $REDIS = Redis.new(url: ENV['REDIS_URL'])
    $ENVIRONMENT = ENV['APP_ENV']
    $CACHE_FULL_MENU_EXP_MINUTES = ENV['CACHE_FULL_MENU_EXP_MINUTES']
    $CACHE_MENU_EXP_MINUTES = ENV['CACHE_MENU_EXP_MINUTES']
    $CK_URL = ENV['CK_URL']
  end

  before do
    last_modified settings.start_time
    etag settings.start_time.to_s
    cache_control
  end

  get '/campus/:campus/menu' do
    campus_hash = {
      type: 'path',
      key: 'campus',
      value: params[:campus]
    }

    type_hash = {
      type: 'query',
      key: 'type',
      value: params[:type]
    }

    campus, type = validate_required_params([campus_hash, type_hash])

    @menu = ''

    include_array = params[:include].nil? ? nil : params[:include].split(',')
    exclude_array = params[:exclude].nil? ? nil : params[:exclude].split(',')
    price_hash = {
      eq: params[:eq],
      gt: params[:gt],
      lt: params[:lt],
      ge: params[:ge],
      le: params[:le]
    }
    not_customized = include_array.nil? && exclude_array.nil? && price_hash.values.all? { |value| value.nil? }

    if type == 'Full'
      if not_customized
        @menu = FullMenu.new($CK_URL, campus).html
      else
        route = menu_route_builder(campus, 'custom', params[:include], params[:exclude], price_hash)
        redirect to(route)
      end
    else
      base_menu = FullMenu.new($CK_URL, campus).html

      @menu =
        if type == 'Custom' && not_customized
          base_menu
        else
          FilterMenu.new(base_menu, type, campus, include_array, exclude_array, price_hash).html
        end
    end

    etag menu_route_builder(campus, type, include_array, exclude_array, price_hash)
    haml :'../pages/menu'
  rescue StandardError => e
    redirect to('/500')
  end
end
