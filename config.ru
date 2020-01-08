# frozen_string_literal: true

require 'active_support/all'
require 'require_all'
require 'route_downcaser'
require 'sass/plugin/rack'
require 'sinatra/base'

require_all './app/controllers'

Sass::Plugin.options[:style] = :compressed

use Sass::Plugin::Rack
use RouteDowncaser::DowncaseRouteMiddleware
use CampusesController
use MenuTypesController
use MenusController
use ErrorsController
run ApplicationController
