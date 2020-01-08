# frozen_string_literal: true

require_relative 'food_category'
require_relative '../helpers/application_helper'

# Contains data related to menu types
class MenuTypes

  def self.pescatarian
    {
      food_categories: [
        'red_meats',
        'white_meats'
      ].flatten,
      words: [
        FoodCategory.red_meats,
        FoodCategory.white_meats
      ].flatten,
      more_restrictive_menu_types: [
        'vegetarian',
        'vegan'
      ]
    }
  end

  def self.vegetarian
    {
      food_categories: [
        self.pescatarian[:food_categories],
        'seafood'
      ].flatten,
      words: [
        self.pescatarian[:words],
        FoodCategory.seafood
      ].flatten,
      more_restrictive_menu_types: [ 'vegan' ]
    }
  end

  def self.vegan
    {
      food_categories: [
        self.vegetarian[:food_categories],
        'baked_goods',
        'dairy_products',
        'vegan_other'
      ].flatten,
      words: [
        self.vegetarian[:words],
        FoodCategory.baked_goods,
        FoodCategory.dairy_products,
        FoodCategory.vegan_other
      ].flatten,
      more_restrictive_menu_types: []
    }
  end

  def self.presets
    [
      'pescatarian',
      'vegetarian',
      'vegan'
    ]
  end

  def self.non_custom
    MenuTypes.all - ['custom']
  end

  def self.all
    [
      'full',
      self.presets,
      'custom'
    ].flatten
  end
end
