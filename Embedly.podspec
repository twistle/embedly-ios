Pod::Spec.new do |spec|
    spec.name     = 'Embedly'
    spec.version  = '1.1'
    spec.source   = { :git => 'https://github.com/twistle/embedly-ios.git'}
    spec.source_files = 'Classes/*.{h,m}'
    spec.requires_arc = true
end
