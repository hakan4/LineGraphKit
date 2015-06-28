Pod::Spec.new do |s|
  s.name = 'LineGraphKit'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'Elegant and simple LineGraph in Swift'
  s.homepage = 'https://github.com/hakan4/LineGraphKit'
  s.authors = { 'Hakan Andersson' => 'hakan4@kth.se' }
  s.source = { :git => 'https://github.com/hakan4/LineGraphKit.git' }
  s.ios.deployment_target = '8.0'

  s.source_files = 'LineGraphKit/LineGraphKit/*.swift'

  s.requires_arc = true
end
