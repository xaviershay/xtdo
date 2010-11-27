Gem::Specification.new do |s|
  s.name     = 'xtdo'
  s.version  = '0.1'
  s.summary  = 'Minimal and fast command line todo manager'
  s.platform = Gem::Platform::RUBY
  s.authors  = ["Xavier Shay"]
  s.email    = ["hello@xaviershay.com"]
  s.homepage = "http://github.com/xaviershay/xtdo"
  s.has_rdoc = false

  s.files    = Dir.glob("{spec,lib}/**/*.rb") + 
               Dir.glob("bin/*") +
               %w(README.rdoc HISTORY LICENSE Rakefile TODO)

  s.bindir       = 'bin'
  s.require_path = 'lib'
  s.executables << %q{xtdo}

  s.add_development_dependency 'rspec', '~> 2.1.0'
  s.add_development_dependency 'timecop'
end
