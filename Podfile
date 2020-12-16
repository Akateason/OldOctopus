
source 'https://github.com/CocoaPods/Specs.git'



def commonPods
      pod 'XTBase'
      pod 'XTlib'
      pod 'XTlib/Animations'
      pod 'XTlib/CustomUIs'
      pod 'XTIAP'

      pod 'IQKeyboardManager'
      pod 'EllipsePageControl'
      pod 'lottie-ios','2.5.3'
      pod 'MSDynamicsDrawerViewController'
      pod 'SSZipArchive'
      pod 'JTMaterialSwitch'
      pod 'MBProgressHUD', '~> 1.1.0'
      pod 'MGSwipeTableCell'
      pod 'CocoaLumberjack'
      pod 'FTPopOverMenu'
      pod 'WKWebViewWithURLProtocol'
      pod 'UMCCommon'
      
#      pod 'UMCAnalytics'

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


