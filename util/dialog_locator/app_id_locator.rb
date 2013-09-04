#encoding: utf-8

module AppIdLocator

  def id(arg) 
    @driver.find_element(:xpath => $data[:xpath][:app_id_page][arg])
  end

  def builds(arg)
    @driver.find_element(:xpath => $data[:xpath][:app_builds_page][arg])
  end

  def collaborators(arg)
    @driver.find_element(:xpath => $data[:xpath][:app_collaborators_page][arg])
  end

  def settings(arg)
    @driver.find_element(:xpath => $data[:xpath][:app_settings_page][arg])
  end
end

