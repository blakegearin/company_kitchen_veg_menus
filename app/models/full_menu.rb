# frozen_string_literal: true

require 'chromedriver-helper'
require 'fileutils'
require 'open-uri'
require 'watir'

require_relative '../helpers/application_helper'

require_all 'app/models'

# Contains logic to scrape a full menu
class FullMenu < Menu
  attr_reader :html

  def initialize(url, campus)
    type = 'Full'
    cache_key = "#{$ENVIRONMENT}_#{menu_route_builder(campus, type, nil, nil, { nil: nil } )}"

    # Check cache before continuing
    cache_value = $REDIS.get(cache_key)
    unless cache_value.nil?
      @html = cache_value
      return
    end

    menu_html_string, url_updated = scrape_menu_html(url, campus)

    scraped_path_arrays = scrape_file_link(menu_html_string)
    scraped_path_arrays.each do |scraped_path_array|
      menu_html_string = overwrite_file_links(scraped_path_array, url_updated, menu_html_string)
    end

    full_menu_file = Nokogiri::HTML(menu_html_string)
    menu_name = "#{type} Menu"
    update_menu_headers(full_menu_file, menu_name, campus)

    # Remove CK's version of Bootstrap
    full_menu_file.xpath('//link/@href').each do |link|
      if link.value == "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
        link.remove
      end
    end

    # Apply invert-logo class to logos that are not dark theme friendly
    invert_logo_array = [
      'Pop-Up',
      'Baker & Butcher',
      'Novita'
    ]
    full_menu_file.css('.print-eatery').each do |eatery|
      title = eatery.css('h2').text
      if invert_logo_array.include?(title)
        eatery.search('.logo')[0]['class'] = 'logo invert-logo'
      end
    end

    @html = full_menu_file.inner_html

    # Cache menu
    cache(cache_key, @html)
  rescue Watir::Wait::TimeoutError, StandardError => e
    puts "#{$X_MARK} Error: Couldn't scrape menu from the CK website for \"#{campus}\""
    puts e.message
  end

  private

  # Replaces relative links in the original HTML with the full URL
  def overwrite_file_links(paths_array, url, menu_html_string)
    paths_array.each do |path|
      full_url_path = url + path.gsub(/\?[\S]+/, '')
      menu_html_string.gsub!(path, full_url_path)
    end

    menu_html_string
  end

  # Scrapes all links to PNGs and CSS files referenced by the menu
  def scrape_file_link(menu_html_string)
    scraped_png_url_paths = []
    scraped_css_url_paths = []

    # Get strings wrapped in quotation marks
    scarped_strings = menu_html_string.scan(/\"[\S]+\"/)

    # Remove double quotation marks
    scarped_strings.map! { |string| string.gsub(/"/, '') }

    scarped_strings.each do |string|
      scraped_png_url_paths.push(string) unless string.scan('.png').empty?
      scraped_css_url_paths.push(string) unless string.scan('.css').empty?
    end

    scraped_png_url_paths = scraped_png_url_paths.uniq.map { |string| string unless string.scan('images').empty? }.compact
    scraped_css_url_paths = scraped_css_url_paths.uniq.map { |string| string if string.scan('http').empty? }.compact

    [
      scraped_png_url_paths,
      scraped_css_url_paths
    ]
  end

  # Creates a headless Chrome browser instance
  def new_browser
    options = Selenium::WebDriver::Chrome::Options.new

    # Make a directory for chrome if it doesn't already exist
    chrome_dir = File.join Dir.pwd, %w(tmp chrome)
    FileUtils.mkdir_p chrome_dir
    user_data_dir = "--user-data-dir=#{chrome_dir}"

    # Add the option for user-data-dir
    options.add_argument user_data_dir

    # Let Selenium know where to look for chrome if we have a hint from Heroku
    # chromedriver-helper & chrome seem to work out of the box on osx, but not on Heroku
    if chrome_bin = ENV["GOOGLE_CHROME_SHIM"]
      options.add_argument "--no-sandbox"
      options.binary = chrome_bin
    end

    # Headless arguments
    options.add_argument "--window-size=1200x600"
    options.add_argument "--headless"
    options.add_argument "--disable-gpu"

    # Make the browser
    browser = Watir::Browser.new :chrome, options: options

    browser
  end

  # Scrapes the html of the menu for a particular campus
  def scrape_menu_html(url, campus)
    browser = new_browser
    browser.goto url
    raise "Couldn\'t reach url \"#{url}\"" if browser.html.include? 'This site can’t be reached'

    url_updated = browser.url.end_with?('/') ? browser.url.chop : browser.url

    browser.div(class: 'tray').ul.li(:text => /#{campus}/).button.wait_until(&:present?)
    browser.div(class: 'tray').ul.li(:text => /#{campus}/).button.click!

    print_menu_url = '/menu/print'
    browser.goto url_updated + print_menu_url
    browser.div(class: 'print-eatery').wait_until(&:present?)

    menu_html_string = browser.html
    browser.close

    [
      menu_html_string,
      url_updated
    ]
  end
end
