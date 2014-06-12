Gem::Specification.new do |s|
  s.name              = "epic-geo"
  s.version           = "0.0.4"
  s.platform          = Gem::Platform::RUBY
  s.authors           = ["Jennings Anderson"]
  s.email             = ["jennings.anderson@colorado.edu"]
  s.homepage          = "http://github.com/jenningsanderson/epic-geo"
  s.summary           = "Gems for handling Project EPIC geo data"
  s.description       = "Series of Ruby Scripts for dealing with Geo data.  Much more to come"
  s.rubyforge_project = s.name

  #s.required_rubygems_version = ">= 1.3.6"

  # If you have runtime dependencies, add them here
  # s.add_runtime_dependency "other", "~> 1.2"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "rgeo" #This is an important dependency to allow the geo calculations
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
