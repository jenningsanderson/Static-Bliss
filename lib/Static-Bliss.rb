require 'yaml'

class StaticBliss

	def initialize(command, args)
		puts "Command: #{command}"
		puts "args: #{args}"

		puts "Reading the _config.yml file"
		read_config
		puts ""

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
			return false
		end
	end



	#This function uses the secret Amazon s3 credentials to publish the site to an s3 Bucket
	#defined in the config
	def publish( *args )
		puts "Publishing the site to: #{@credentials['production_bucket']}"
		
		#Require the bucket manager and make the connection, then publish
		require_relative 'aws/bucket_manager'
		@manager = BucketManager.new(@credentials['s3_id'], @credentials['s3_secret'])
    	@manager.connect_to_bucket(@credentials['production_bucket'])

    	puts `jekyll build`
  	
  		@manager.write_directory('_site')
	end



	#This workhorse function takes a variety of arguments and allows for 
	def update( *args )
		args.flatten!
		
		require_relative 'google_drive/object_types'
		require_relative 'google_drive/parse_to_yaml'

		@connection = GoogleDriveYAMLParser.new(@credentials['google_username'], @credentials['google_password'], @site_config)

		sheet = args.shift
		types  = [args.shift]
		if (types[0].nil? or types[0]=='all')
			types = @site_config['google_info'][sheet]['types']
		end

		parameters = args
		
		unless sheet == 'all'
			begin
				key 	= @site_config['google_info'][sheet]['key']
				object 	= @site_config['google_info'][sheet]['object']

				types.each do |this_type|
					#Hit google
					puts "\nHitting Google for #{sheet} of type #{this_type}"
					data_to_write = @connection.read_sheet key, this_type.capitalize, object, parameters
					#Write data
					@connection.write_to_yaml data_to_write, @site_config['data_directory'], this_type.capitalize
					puts "========================================================"
				end
			
			rescue => error
				puts error.inspect
				puts "Error, that type of object doesn't exist for this site"
				puts error.backtrace
			end
		else
			puts "Doing all the updates"
			puts "Will iterate through each object type and run the appropriate functions"
		end
	end

	def flickr(*args)
		require_relative 'flickr/flickr_connect'
		#Should be able to choose the set that you want here...

		flickr_sets = @site_config['flickr']
		data_dir = @site_config['data_directory']


		flickr_sets.keys.each do |flickr_set|
			puts "\tProcessing #{flickr_set}"
			config = {
				:api_key => @credentials['flickr_api_key'],
				:set => flickr_sets[flickr_set]['set']
			}

			flickr_manager = FlickrConnect.new(config)
			flickr_manager.get_photos
			flickr_manager.write_yaml(data_dir, flickr_set)
		end
	end

	def help(*args)
		puts "Welcome to Static-Bliss, a gem built to make updating your jekyll site very simple."
		
		if read_config
			puts "\nThe following functions are available based on your configuration:"
			
			if @credentials['production_bucket']
				puts "\tbliss publish"
			end

			if @credentials['flickr_api_key']
				puts "\tbliss flickr"
				@site_config['flickr'].keys.each do |set|
					puts "\tbliss flickr #{set}"
				end
			end
			
			@site_config['google_info'].each do |object, vals|
				if vals['types'].count > 1
					puts "\tbliss update #{object} [all]"
					vals['types'].each do |type|
						puts "\tbliss update #{object} #{type}"
					end
				else
					puts "\tbliss update #{object}"
				end
			end
			puts "\tbliss update all"
			puts "\nNote: Additional parameters for each of these functions may be available depending on your object classes"
		end
	end
end
