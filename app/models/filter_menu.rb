# frozen_string_literal: true

# Required for pluralize
require 'active_support/inflector'

require_relative '../helpers/application_helper'

require_all 'app/models'

# Contains logic to build a custom menu by filtering a base menu
class FilterMenu < Menu
  attr_reader :html

  def initialize(base_menu, type, campus, include_array, exclude_array, price_hash)
    include_string = include_array.nil? ? nil : include_array.join(',')
    exclude_string = exclude_array.nil? ? nil : exclude_array.join(',')
    cache_key = "#{$ENVIRONMENT}_#{menu_route_builder(campus, type, include_string, exclude_string, price_hash)}"

    # Check cache before continuing
    cache_value = $REDIS.get(cache_key)
    unless cache_value.nil?
      @html = cache_value
      return
    end

    menu_file = Nokogiri::HTML(base_menu)

    custom_menu = (type == 'Custom')
    customized_menu = (include_array.not_nil? || exclude_array.not_nil?) && !custom_menu
    menu_name = "#{'Customized ' if customized_menu}#{type.capitalize} Menu"
    update_menu_headers(menu_file, menu_name, campus)

    complete_exclude_array = custom_menu ? [] : MenuTypes.send(type.downcase)[:words]
    complete_exclude_array += exclude_array unless exclude_array.nil?

    filter_menu(type, menu_file, include_array, complete_exclude_array, price_hash)
    delete_empty_eateries(menu_file)

    @html = menu_file.inner_html

    # Cache menu
    cache(cache_key, @html)
  end

  private

  def word_in_array?(array, word)
    singular_found = array.include?(word)
    plural_found = array.include?(word.pluralize)

    singular_found || plural_found
  end

  def get_words_array(string)
    string.
      # Remove special characters
      gsub(/[^\w\n ]/, '').
      # Split by newline
      split("\n").
      # Split each by spaces
      map { |item| item.split() }.
      # Remove dimensionality
      flatten.
      # Change all words to lowercase
      map!(&:downcase)
  end

  def contains_choice?(words_array, index)
    choice_search_distance = 4
    starting_index = (index-choice_search_distance < 0) ? 0 : index-choice_search_distance

    words_around_current_word = words_array[starting_index..index]
    words_around_current_word.include?('choice')
  end

  def contains_free?(words_array, index)
    free_search_distance = 1
    starting_index = (index-free_search_distance < 0) ? 0 : index-free_search_distance
    ending_index = (index+free_search_distance > words_array.length) ? words_array.length : index+free_search_distance

    words_around_current_word = words_array[starting_index..ending_index]
    words_around_current_word.include?('free')
  end

  # Examines a menu item to see if it contains an exclude word
  def exclude_word_found?(raw_input, exclude_array, type)
    words_array = get_words_array(raw_input)
    remove = false

    for i in 0..words_array.length-1 do
      current_word = words_array[i]

      if word_in_array?(exclude_array, current_word)
        next if contains_choice?(words_array, i)
        next if contains_free?(words_array, i)

        remove = true
      end
    end

    if type != 'Custom'
      contains_or_tofu = words_array.include?('or') && words_array.include?('tofu')
      contains_type = words_array.include?(type.downcase)
      contains_more_restrictive_type =
        words_array & MenuTypes.send(type.downcase)[:more_restrictive_menu_types] != []

      remove = false if (contains_or_tofu || contains_type || contains_more_restrictive_type)
    end

    remove
  end

  def filter_on_exclude(item_name_raw, item_description_raw, exclude_array, type)
    exclude_based_on_name = exclude_word_found?(item_name_raw, exclude_array, type)
    exclude_based_on_description = exclude_word_found?(item_description_raw, exclude_array, type)

    (exclude_based_on_name || exclude_based_on_description)
  end

  # Examines a menu item to see if it contains a word
  def include_word_found?(raw_input, include_words)
    words_array = get_words_array(raw_input)

    found = false
    for i in 0..words_array.length-1 do
      current_word = words_array[i]

      found = true if word_in_array?(include_words, current_word)
    end

    found
  end

  def filter_on_include(item_name_raw, item_description_raw, include_array)
    include_based_on_name = include_word_found?(item_name_raw, include_array)
    include_based_on_description = include_word_found?(item_description_raw, include_array)

    (include_based_on_name || include_based_on_description)
  end

  def filter_on_price(item_price, operator_symbol_string, filter_price)
    item_price.method(operator_symbol_string).(filter_price.to_f)
  end

  # Returns the name and description of a menu item
  def get_item_details(menu_item)
    item_name_raw = menu_item.at_css('.print-level1').at_css('.name').inner_html
    item_description_raw =
      if menu_item.at_css('.print-description') == nil
        'No description found'
      else
        menu_item.at_css('.print-description').inner_html
      end
    item_price = menu_item.at_css('.price').text.gsub('$','').to_f

    [
      item_name_raw,
      item_description_raw,
      item_price
    ]
  end

  def filter_menu(type, menu_file, include_array, exclude_array, price_hash)
    menu_items = menu_file.css('.print-product')
    menu_items.each do |menu_item|
      item_name_raw, item_description_raw, item_price = get_item_details(menu_item)

      unless include_array.nil?
        included = filter_on_include(item_name_raw, item_description_raw, include_array)
        unless included
          menu_item.remove
          next
        end
      end

      unless exclude_array.nil?
        exclude = filter_on_exclude(item_name_raw, item_description_raw, exclude_array, type)
        if exclude
          menu_item.remove
          next
        end
      end

      unless price_hash.values.all? { |value| value.nil? }
        price_hash.each do |operator_string, filter_price|
          unless filter_price.nil?
            include = filter_on_price(item_price, Operator.all[operator_string], filter_price)

            unless include
              menu_item.remove
              next
            end
          end
        end
      end
    end
  end

  def delete_empty_eateries(menu_file)
    eateries = menu_file.css('.print-eatery')
    eateries.each do |eatery|
      eatery.remove if eatery.css('.print-product').empty?
    end
  end
end
