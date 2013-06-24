Pod::Spec.new do |s|
  s.name         = "VISlideMenu"
  s.version      = "0.0.1"
  s.summary      = "An implementation of the common slide menu."
  s.homepage     = "https://github.com/vilea/VISlideMenu"
 
  s.license      = { :type => 'Custom', :file => 'LICENSE.markdown' }

  s.author       = { "Junior Bontognali" => "junior.bontognali@vilea.ch" }
  s.source       = { :git => "https://github.com/vilea/VISlideMenu.git", :tag => "0.0.1" }

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'

  s.source_files = 'VISlideMenu/Source/*.{h,m}'
  s.exclude_files = 'VISlideMenu/Demo'

  s.public_header_files = 'VISlideMenu/Source/**/*.h'
  
  s.requires_arc = true
end
