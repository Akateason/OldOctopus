
source 'https://github.com/CocoaPods/Specs.git'



def commonPods
      pod 'XTBase'
      pod 'XTlib'
      pod 'XTlib/Animations'
      pod 'XTlib/CustomUIs'
      pod 'XTIAP'

    #pod 'XTBase',:path => '../XTBase/'
    #pod 'XTlib',:path => '../../teason_project/XTlib/'
    #pod 'XTlib/Animations',:path => '../../teason_project/XTlib/'
    #pod 'XTlib/CustomUIs',:path => '../../teason_project/XTlib/'
    #pod 'XTIAP',:path => '../XTIAP/'

      pod 'IQKeyboardManager'
      pod 'SDWebImage','<=4.4.6'
      pod 'EllipsePageControl'
      pod 'lottie-ios','2.5.3'
      pod 'iosMath'
      pod 'MSDynamicsDrawerViewController'
      pod 'SSZipArchive'
      pod 'JTMaterialSwitch'
      pod 'MBProgressHUD', '~> 1.1.0'
      pod 'MGSwipeTableCell'
      pod 'CocoaLumberjack'
      pod 'FTPopOverMenu'
      pod 'WKWebViewWithURLProtocol'
end



target 'Notebook' do
  use_frameworks!

  commonPods
  
  #mac不支持 以下
  pod 'AipOcrSdk-release', :configurations => ['Release']
  pod 'AipOcrSdk', :configurations => ['Debug']
  pod 'Bugly','2.5.0'
end


target 'NotebookMac' do
  use_frameworks!

  commonPods
end


