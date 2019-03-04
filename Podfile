source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!
inhibit_all_warnings!


def defaults
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'


end

def test 

	pod 'RxBlocking', '~> 4.0'
    pod 'RxTest', '~> 4.0'

end


target 'textPreviwer' do
    defaults
end

target 'textPreviwerTests' do
    defaults
    test
end


target 'textPreviwerUITests' do
    defaults
    # Pods for testing
end