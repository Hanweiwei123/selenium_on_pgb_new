#encoding: utf-8

module AppIdLocator

  def app_brief(arg)
    highlight_and_return @driver.find_element(:xpath => $data[:xpath][:app_id_page][arg])
  end

  def builds(arg)
    highlight_and_return @driver.find_element(:xpath => $data[:xpath][:app_builds_page][arg])
  end
  
  def plugins(arg)
    highlight_and_return @driver.find_element(:xpath => $data[:xpath][:app_plugins_page][arg])
  end

  def collaborators(arg)
    highlight_and_return @driver.find_element(:xpath => $data[:xpath][:app_collaborators_page][arg])
  end

  def settings(arg)
    highlight_and_return @driver.find_element(:xpath => $data[:xpath][:app_settings_page][arg])
  end

  def abuse(arg)
    highlight_and_return @driver.find_element(:xpath => $data[:xpath][:app_abuse_page][arg])
  end

  def install_btn(platform)
    platforms = ['ios', 'android', 'webos', 'blackberry', 'symbian', 'winphone']
    raise "Not support platform: #{platform}" unless platforms.include?(platform)
    app = @driver.find_element(:xpath, "//div[@class='packages clearfix']/div[@class='platform ui-block #{platform}']/a")
    app
  end
 
end

