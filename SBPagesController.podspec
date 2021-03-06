Pod::Spec.new do |s|

  s.name         = "SBPagesController"
  s.version      = "0.0.3"
  s.summary      = "This is my amazing Swift CocoaPod!"
 
  s.description  = <<-DESC
                    Scroll multiple view controllers horizontally with the ability of tracking
                    scroll's progress between pages.
                   DESC
 
  s.homepage = "https://github.com/salimbraksa/SBPagesController"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Braksa Salim" => "salim.braksa@gmail.com" }
  s.social_media_url   = "https://twitter.com/salimbraksa"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/salimbraksa/SBPagesController.git", :tag => s.version }
  s.source_files  = "SBPagesController/*.swift"

  s.dependency 'Cartography'

end
