Pod::Spec.new do |s|

  s.name          = "ZCPCarouselView"
  s.version       = "0.0.1"
  s.summary       = "It`s a framework."
  s.description   = <<-DESC
                      It`s a framework for myself.
                    DESC

  s.homepage      = "https://github.com/MagicianMalygos/ZCPCarouselView"
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { "朱超鹏" => "z164757979@163.com" }
  s.source        = { :git => "https://github.com/MagicianMalygos/ZCPCarouselView.git", :tag => "#{s.version}" }
  
  s.platform      = :ios, '9.0'
  s.framework     = 'Foundation', 'UIKit'

# ――― Subspec ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.subspec 'Swift' do |ss|
    ss.public_header_files = 'ZCPCarouselView/ZCPCarouselView_Swift/**/*.h'
    ss.source_files  = 'ZCPCarouselView/ZCPCarouselView_Swift/**/*.{h,m}'
  end

  s.subspec 'OC' do |ss|
    ss.public_header_files = 'ZCPCarouselView/ZCPCarouselView_OC/**/*.h'
    ss.source_files = 'ZCPCarouselView/ZCPCarouselView_OC/**/*.{h,m}'
  end

end