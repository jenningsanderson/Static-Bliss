class StaticBliss
	require_relative 'aws/bucket_manager'

	def initialize
		puts "Initialized Static Bliss"
	end
	
	def self.hi
		puts "Hello world!"
	end
end