Gem::Specification.new do |s|
  s.name              = "Static-Bliss"
  s.version           = "0.0.1"
  s.platform          = Gem::Platform::RUBY
  s.authors           = ["Jennings Anderson"]
  s.email             = ["jennings.anderson@colorado.edu"]
  s.homepage          = "http://github.com/jenningsanderson/Static-Bliss"
  s.summary           = "A gem for quazi-dynamic updating and publishing to static sources"
  s.description       = "A lot of development happening here..."
  s.rubyforge_project = s.name

  #s.required_rubygems_version = ">= 1.3.6"

  # If you have runtime dependencies, add them here
  # s.add_runtime_dependency "other", "~> 1.2"
  #s.add_runtime_dependency "json"
  #s.add_runtime_dependency "rgeo" #This is an important dependency to allow the geo calculations
  # It will need all sorts of dependencies such as rgeo, ruby/gems, etc...

  # If you have development dependencies, add them here
  # s.add_development_dependency "another", "= 0.9"

  # The list of files to be contained in the gem
  s.files         = `git ls-files`.split("\n")
  # s.executables   = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  # s.extensions    = `git ls-files ext/extconf.rb`.split("\n")

  s.require_path = 'lib'

  # For C extensions
  # s.extensions = "ext/extconf.rb"
end