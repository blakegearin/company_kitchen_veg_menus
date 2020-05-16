# frozen_string_literal: true

# Contains data related to food categories
class FoodCategory

  def self.dairy_products
    [
      'dairy',
      'butter',
      'buttery',
      'cheese',
      'cheesy',
      'cheddar',
      'cream',
      'milk',
      'mozzarella',
      'parmesan',
      'provolone',
      'queso',
      'yogurt'
    ]
  end

  def self.baked_goods
    [
      'biscuit',
      'brownie',
      'cake',
      'cheesecake',
      'chocolate',
      'cookie',
      'donut',
      'muffin',
      'pastry',
      'pie'
    ]
  end

  def self.seafood
    [
      __method__.to_s,
      'catfish',
      'cod',
      'crab',
      'fish',
      'oyster',
      'salmon',
      'scallop',
      'shrimp',
      'tuna'
    ]
  end

  # Hypothetically this could include seafood, but I feel it's best kept separate
  def self.white_meats
    [
      'chicken',
      'hen',
      'lamb',
      'poultry',
      'rabbit',
      'turkey',
      'veal'
    ]
  end

  def self.red_meats
    [
      'bacon',
      'barbacoa',
      'beef',
      'brisket',
      'dog',
      'duck',
      'goat',
      'goose',
      'ham',
      'hotdog',
      'meat',
      'meatball',
      'mutton',
      'pork',
      'pepperoni',
      'quail',
      'sausage',
      'steak',
      'venison'
    ]
  end

  def self.vegan_other
    [
      'egg',
      'gelatin'
    ]
  end
end
