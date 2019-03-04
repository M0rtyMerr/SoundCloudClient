platform :ios, '12.1'

target 'SoundCloutClient' do
  use_frameworks!
  inhibit_all_warnings!
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxSwiftExt'
  pod 'Moya/RxSwift'
  pod 'Reusable'
  pod 'Then'
  pod 'SwiftLint'
  pod 'Kingfisher'
  pod 'ReactorKit'
  
  target 'SoundCloutClientTests' do
    inherit! :search_paths
    pod 'RxTest'
    pod 'Quick'
    pod 'Nimble'
    pod 'RxNimble'
  end

  target 'SoundCloutClientUITests' do
    inherit! :search_paths
  end

end
