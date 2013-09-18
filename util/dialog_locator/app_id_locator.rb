#encoding: utf-8

module AppIdLocator

  def app_brief(arg)
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

  def abuse(arg)
    highlight_and_return @driver.find_element(:xpath => $data[:xpath][:app_abuse_page][arg])
  end

  def install_btn(platform)
    platforms = ['ios', 'android', 'webos', 'blackberry', 'symbian', 'winphone']
    raise "Not support platform: #{platform}" unless platforms.include?(platform)
    app = @driver.find_element(:xpath, "//div[@class=\"packages clearfix\"]/div[@class=\"platform ui-block #{platform}\"]/a")
    app
  end
  
  
  # SigningKey related 

  def add_signingkey_for(platform, title = "SigningkeyTitle") 
    platforms = [:ios, :android, :blackberry]
    raise "Not Supported Platform" unless platforms.include?(platform)

    puts "+ <util>/<dialog_locator>/<app_id_locator.rb>#add_signingkey_for #{platform.to_s}"
    case platform 
    when :ios 
      
      builds(:ios_options).click; sleep 2
      builds(:ios_new_key).click; sleep 2

      builds(:ios_title_input).send_keys title

      if ( win_or_mac == "win" )
        builds(:ios_choose_cert_btn).send_keys("C:\\assets\\signing_key\\ios\\LichuanIQEKey.p12")
        builds(:ios_choose_prov_btn).send_keys("C:\\assets\\signing_key\\ios\\Lichuanlu.mobileprovision")
      else
        builds(:ios_choose_cert_btn).send_keys(File.expand_path($data[:signing_key][:ios][:valid][:cert],__FILE__))
        builds(:ios_choose_prov_btn).send_keys(File.expand_path($data[:signing_key][:ios][:valid][:profile],__FILE__))
      end

      builds(:ios_submit_btn).click
      sleep 10
    when :android 
      builds(:android_options).click; sleep 2
      builds(:android_new_key).click; sleep 2

      builds(:android_title_input).send_keys title
      builds(:android_alias).send_keys title
      if ( win_or_mac == "win" )
        builds(:android_choose_keystore_btn).send_keys("C:\\assets\\signing_key\\android\\android-dilato.keystore")
      else
        builds(:android_choose_keystore_btn).send_keys(File.expand_path($data[:signing_key][:android][:valid][:keystore],__FILE__))            
      end

      builds(:android_submit_btn).click
      sleep 10
    when :blackberry 
      builds(:blackberry_options).click; sleep 2
      builds(:blackberry_new_key).click; sleep 2

      builds(:blackberry_title_input).send_keys title

      if(win_or_mac == "win")
        builds(:blackberry_choose_csk_btn).send_keys("C:\\assets\\signing_key\\blackberry\\barsigner.csk")
        builds(:blackberry_choose_db_btn).send_keys("C:\\assets\\signing_key\\blackberry\\barsigner.db")
      else
        builds(:blackberry_choose_csk_btn).send_keys File.expand_path($data[:signing_key][:blackberry][:valid][:csk],__FILE__)
        builds(:blackberry_choose_db_btn).send_keys File.expand_path($data[:signing_key][:blackberry][:valid][:db],__FILE__)
      end

      builds(:blackberry_submit_btn).click
      sleep 10
    end
  end

  def unlock_signingkey_for platform
    platforms = [:ios, :android, :blackberry]
    raise "Not Supported Platform" unless platforms.include?(platform)

    puts "+ <util>/<dialog_locator>/<app_id_locator.rb>#unlock_signingkey_for #{platform.to_s}"
    case platform 
    when :ios 
      
    when :android 

    when :blackberry 
      
    end
  end

end

