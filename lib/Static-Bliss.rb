require 'yaml'

class StaticBliss

	def initialize(command, args)
		puts "Command: #{command}"
		puts "args: #{args}"

		puts "Reading the _config.yml file"
		read_config

		unless @config.nil?
			build_update_functions
		end

		begin
			instance_eval "#{command} (#{args})"
		rescue
			"oops, failed"
		end

	end

	def read_config
		if File.exists?('_config.yml')
			puts "Loading site_config from _config.yml"
			@site_config = YAML::load(File.open('_config.yml'))
		else
			puts "Entering test environment, _config.yml does not exist"
			@site_config = YAML::load(File.open('spec/_config.yml'))
		end

		if File.exists?(@site_config['credentials'])
			puts "Loading credentials from site_config location"
			@credentials = YAML::load(File.open(@site_config['credentials']))
		else
			puts "You do not have a proper credentials file defined in _config.yml"
		end
	end

	def publish( *args )
		puts "Publishing the site to: #{@credentials['production_bucket']}"
		
		#Require the bucket manager and make the connection, then publish
		require_relative 'aws/bucket_manager'
		@manager = BucketManager.new(@credentials['s3_id'], @credentials['s3_secret'])
    	@manager.connect_to_bucket(@credentials['production_bucket'])

    	`jekyll build --destination _to_upload`
  	
  		@manager.write_directory('_to_upload')
	end

	def update(*args)
		puts "Reached update with args:"
		puts "Args: #{args}"

		require_relative 'google_drive/object_types'
		require_relative 'google_drive/parse_to_yaml'

		sheet = args.shift!
		key = @site_config['google_info'][sheet]['key']
		object = @site_config['google_info'][sheet]['object']

		@connection = GoogleDriveYAMLParser.new(@credentials['google_username'], @credentials['google_password'])
		@connection.set_params(nil)

		@connection.read_sheet @site_config['google_info'][sheet]['key'], sheet, object

		#Now it will call the appropriate update function, based on the arguments passed.

		unless args.include? 'all'
			#update all the pages here, implying, call the update function for all objects
		else
			#Call the update function for what's available
		end
	end

	def help(*args)
		#This will go through dynamically and figure it all out

		puts "Reached help"

	end

end
