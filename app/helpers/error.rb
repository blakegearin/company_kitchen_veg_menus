# frozen_string_literal: true

def build_overwritten_path(path, param_key, param_value, param_type, value_to_replace)
  case param_type
  when 'path'
    updated_path = path.gsub(value_to_replace, param_value)

    first = true
    params.each do |key, value|
      if first
        updated_path += '?'
        first = false
      else
        updated_path += "&"
      end

      updated_path += "#{key}=#{value.downcase}"
    end
  when 'query'
    updated_path = path
    first = true
    params.each do |key, value|
      if first
        updated_path += '?'
        first = false
      else
        updated_path += "&"
      end

      chosen_value = (key == param_key) ? param_value : value
      updated_path += "#{key}=#{chosen_value.downcase}"
    end
  end

  updated_path
end

def build_valid_list(raw_path, raw_list, param_type, param_key, value_to_replace)
  raw_list.sort!
  raw_list.map! do |item|
    path = build_overwritten_path(raw_path, param_key, item.downcase, param_type, value_to_replace)
    "<a href='#{path}'>#{item.capitalize}</a>"
  end
end

def render_error_page(error_type, key, type, value = nil)
  case error_type
  when 'missing'
    redirect_path = "/422?error_type=missing&param_key=#{key}"
  when 'invalid'
    original_request_path = request.path_info.dup
    redirect_path = "/422?error_type=invalid&param_key=#{key}&param_type=#{type}"\
                    "&param_value=#{value}&path=#{original_request_path}"

    params.each do |key, value|
      unless original_request_path.include?(key.downcase)
        redirect_path+= "&#{key.downcase}=#{value.downcase}"
      end
    end
  end

  redirect to(redirect_path)
end
