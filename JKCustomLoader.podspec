#Taken from podspec file for repository - https://github.com/rounak/RJImageLoader/blob/master/RJImageLoader.podspec
# Be sure to run `pod lib lint JKCustomLoader.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JKCustomLoader"
  s.version          = "1.0"
  s.summary          = "A collection of iOS Custom loaders implemented using mask layers"
  s.description      = <<-DESC
                       This is custom loaded library based on the reference from book 'iOS Core Animation: Advanced Techniques' by 'Nick Lockwood'. All animations are based on the mask property of CALayer object. Mask is initially set to zero and then incremented to increase visible portion of the underlying layer.
                       DESC
  s.homepage         = "https://github.com/jayesh15111988/JKCustomLoader/"
  s.license          = 'MIT'
  s.author           = { "Jayesh Kawli" => "j.kawli@gmail.com" }
  s.source           = { :git => "https://github.com/jayesh15111988/JKCustomLoader.git", :branch => 'master' }
  s.social_media_url = 'https://twitter.com/JayeshKawli'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'JKCustomLoader/Classes/*.{h,m}'
end
