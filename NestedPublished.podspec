Pod::Spec.new do |s|
  s.name             = 'NestedPublished'
  s.version          = '1.0.0'
  s.summary          = 'A property wrapper that forwards the objectWillChange of the wrapped ObservableObject to the enclosing ObservableObject's objectWillChange.'
  s.homepage         = 'https://github.com/amzd/NestedPublished'
  s.author           = { 'Casper Zandbergen' => 'info@casperzandbergen.nl' }
  s.source           = { :git => 'https://github.com/amzd/NestedPublished.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/**/*.swift'
end
