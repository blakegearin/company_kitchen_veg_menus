# frozen_string_literal: true

# Contains data related to campuses
class Campus

  # On the CK website, WHQ is the only campus which has a button in all capital letters
  def self.all_caps
    [
      'WHQ'
    ]
  end

    # The other buttons only have the first letter capitalized
  def self.capitalized
    [
      'Continuous',
      'Innovations',
      'Malvern',
      'Realization'
    ]
  end

  def self.all
    self.all_caps + self.capitalized
  end
end
