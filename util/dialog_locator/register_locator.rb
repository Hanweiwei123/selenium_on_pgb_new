#encoding: utf-8 

require_relative "../webdriver_helper"

module RegisterLocator
	include WebdriverHelper

  def select_region(locator, options = {})
    raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
    with = options.delete(:with)
    locator.find_elements(:tag_name => "option").each do |country| 
      if country.attribute('value') == with
        country.click
        break
      end
    end
  end

	def register_locator(arg)
		@driver.find_element(:xpath => $data[:xpath][:register_page][arg])
	end
end