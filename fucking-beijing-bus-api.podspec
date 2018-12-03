
Pod::Spec.new do |s|
    s.name             = 'fucking-beijing-bus-api'
    s.version          = '1.0.5'
    s.summary          = 'beijing bus api'
  
    s.description      = <<-DESC
    beijing bus api
                         DESC
  
    s.homepage         = 'https://github.com/leavez/fucking-beijing-bus-api'
    s.license          = { :type => 'MIT' }
    s.author           = { 'leavez' => 'gaojiji@gmail.com' }
    s.source           = { :git => 'https://github.com/leavez/fucking-beijing-bus-api.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '9.0'
    s.watchos.deployment_target = '4.0'
  
    s.source_files = 'Sources/**/*.{swift}'
  
    s.dependency "Alamofire"
    s.dependency "Mappable"
  
  end
  
