# frozen_string_literal: true

# Contains logic to build menus
class Menu

  # Updates the menu file with specific menu information
  def update_menu_headers(menu_file, menu_name, campus)
    # Overwrite title
    page_title = menu_file.at_css 'title'
    page_title.content = "#{campus} - #{menu_name}"

    # Overwrite menu name
    h1_menu_title = menu_file.at_css 'h1'
    h1_menu_title.content = menu_name

    add_campus(menu_file, h1_menu_title, campus)
    add_generated_on(menu_file, h1_menu_title)
  end

  # Adds a key-value pair to the cache
  def cache(key, value, full = nil)
    expire_seconds = 60 * (full.nil? ? $CACHE_MENU_EXP_MINUTES.to_i : $CACHE_FULL_MENU_EXP_MINUTES.to_i)
    $REDIS.set(key, value, options = { ex: expire_seconds })
  end

  private

  # Inject campus before the menu title if it doesn't already exist
  def add_campus(menu_file, element_after, campus)
    campus_text = "#{campus} Campus"
    campus_id = 'campusTitle'
    campus_element = menu_file.at_css("[id='#{campus_id}']")

    if campus_element.nil?
      h3_campus = "<h3 id='#{campus_id}'style='text-align: center;'>#{campus_text}</h3>"
      element_after.add_previous_sibling(h3_campus)
    end
  end

  # Inject generated on date after the menu title or update it if it exists
  def add_generated_on(menu_file, element_before)
    formatted_datetime = DateTime.now.new_offset('-06:00').strftime("%A, %B %d, %Y at %k:%M CST")
    generated_on_text = "Generated on #{formatted_datetime}"
    generated_on_id = 'generatedOn'

    generated_on_element = menu_file.at_css("[id='#{generated_on_id}']")
    if generated_on_element.nil?
      h4_datetime = "<h4 id='#{generated_on_id}' style='text-align: center;'>#{generated_on_text}</h4>"
      element_before.add_next_sibling(h4_datetime)
    else
      generated_on_element.content = generated_on_text
    end
  end
end
