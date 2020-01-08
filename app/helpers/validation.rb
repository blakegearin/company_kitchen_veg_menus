# frozen_string_literal: true

require 'erb'
require 'require_all'

require_relative 'error'

require_all 'app/models'

def required_params_present?(required_param_array)
  required_param_array.each do |required_param_hash|
    if required_param_hash[:value].nil?
      required_param_keys = required_param_array.map{ |required_param| required_param[:key] }
      render_error_page('missing', required_param_hash[:key], required_param_keys)
    end
  end
end

def validate_param(required_param_hash)
  type = required_param_hash[:type]
  key = required_param_hash[:key]
  value = required_param_hash[:value]

  case key
  when 'campus'
    if Campus.all_caps.map(&:downcase).include?(value)
      value.upcase!
    elsif Campus.capitalized.map(&:downcase).include?(value)
      value.capitalize!
    else
      render_error_page('invalid', key, type, value)
    end
  when 'type'
    if MenuTypes.all.include?(value)
      value.capitalize
    else
      render_error_page('invalid', key, type, value)
    end
  else
    puts "#{$X_MARK} Invalid param_key: \"#{key}\""
  end
end

def validate_required_params(required_param_array)
  required_params_present?(required_param_array)

  valid_param_values = []

  required_param_array.each do |required_param_hash|
    valid_param_value = validate_param(required_param_hash)
    valid_param_values.push(valid_param_value)
  end

  valid_param_values
end
