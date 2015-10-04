Gem::Specification.new do |s|
  s.name              = "Static-Bliss"
  s.version           = "1.2.1"
  s.platform          = Gem::Platform::RUBY
  s.authors           = ["Jennings Anderson"]
  s.email             = ["jennings.anderson@colorado.edu"]
  s.homepage          = "http://github.com/jenningsanderson/Static-Bliss"
  s.summary           = "A gem for quazi-dynamic updating and publishing to static sources"
  s.description       = "A lot of development happening here... hang tight!"
  s.rubyforge_project = s.name
  s.license           = "MIT"

 

  # If you have runtime dependencies, add them h
  s.add_runtime_dependency "commander"
  s.add_runtime_dependency "nokogiri", "1.6.5"

  #only required if you're publishing to an s3 bucket
  # s.add_runtime_dependency "aws-sdk" #This is an important dependency to allow the geo calculations
  # The list of files to be contained in the gem
  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  # s.extensions    = `git ls-files ext/extconf.rb`.split("\n")

  s.require_path = 'lib'

end
