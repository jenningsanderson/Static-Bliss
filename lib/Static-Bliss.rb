class StaticBliss
	require_relative 'aws/bucket_manager'
	require_relative 'google_drive/object_types'
	require_relative 'google_drive/parse_to_yaml'


	# This should eventually accept all the credentials to make EVERYTHING work... THAT
	# would be really, really cool, or perhaps it just calls from the config file? maybe
	# it can parse the config.yml --- err, not
	def initialize
		puts "Initialized Static Bliss"
	end
	
	def self.hi
		puts "Hello world!"
	end
end

