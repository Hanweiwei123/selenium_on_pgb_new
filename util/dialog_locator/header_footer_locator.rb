#encoding: utf-8

module HeaderFooterLocator

  define_method :header_get do |xpth|
    @driver.find_element(:xpath => $data[:xpath][:header][xpth]) 
  end

  def sign_out
    header_get(:account_navlink_edit).click
    header_get(:account_navlink_sign_out).click
  end

  def account_notice
    header_get(:account_notice)
  end

  def go_to_page_edit_account
    header_get(:account_navlink_edit).click
    header_get(:account_navlink_edit_account).click
  end

  LANGS = {
      :english => "en_US",
      :french => "fr_FR",
      :japanese => "ja_JP",
      :chinese => "zh_CN"
  }

  def change_language_to(lang)
    unless LANGS.include?(lang)
      puts "Available languages are: "
      LANGS.each_key {|key| puts ":#{key}" }
      raise "#{lang} was not available"
    end
    lang_select = @driver.find_element(:xpath => @data_xpath[:footer][:nav_select_locale])
    languages = lang_select.find_elements(:tag_name => 'option')
    languages.each do |lan|
      if(lan.attribute('value') == LANGS[lang.to_sym])
        lan.click
        break
      end
    end
  end
end