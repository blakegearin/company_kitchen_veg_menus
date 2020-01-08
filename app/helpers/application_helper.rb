# frozen_string_literal: true

require 'date'
require 'nokogiri'

$CHECK_MARK = "\u2713".encode('utf-8')
$X_MARK = "\u2717".encode('utf-8')

  # Creates a menu path based on campus & type
  def menu_route_builder(campus, type, include_string, exclude_string, price_hash)
    route = "/campus/#{campus.downcase}/menu?type=#{type.downcase}"

    route += "&exclude=#{exclude_string}" if exclude_string.not_nil?
    route += "&include=#{include_string}" if include_string.not_nil?

    if !price_hash.values.all? { |value| value.nil? }
      price_hash.each do |key, value|
        route += "&#{key}=#{value}" unless value.nil?
      end
    end

    route
  end

class Object
  def not_nil?
    !nil?
  end
end
