Pod::Spec.new do |s|
  s.name             = 'Notebook'
  s.version          = '0.0.1'
  s.summary          = 'A short description of Notebook.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/akateason/Notebook'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'teason' => 'akateason@qq.com' }
  s.source           = { :git => 'https://github.com/akateason/Notebook.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Notebook/Classes/**/*'

  # s.resource_bundles = {
  #   'Notebook' => ['Notebook/Assets/*.png']
  # }

  #s.subspec 'Notebook' do | sm |
      #sm.source_files = 'Notebook/ZYSubModule/**/*'
      #sm.dependency 'AFNetworking', '~> 2.3'
  #end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
