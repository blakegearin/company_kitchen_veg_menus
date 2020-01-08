# frozen_string_literal: true

# Contains data related to operator
class Operator
  def self.all
    {
      lt: '<',
      gt: '>',
      le: '<=',
      ge: '>=',
      eq: '=='
    }
  end
end
