require 'yaml'
require 'net/http'
require 'json'

require_relative 'google_drive/models'

class StaticBliss

	attr_reader :site_config, :credentials, :data_dir

	def initialize(args={})
		print "Loading _config.yml file... "
		read_config
		@data_dir = args["data_directory"] || './_data'
	end

	def read_config
		if File.exists?('_config.yml')
			@site_config = YAML::load(File.open('_config.yml'))
			puts "done"
		else
			@site_config = YAML::load(File.open('spec/_config.yml'))
			puts "WARN: entering test env: (spec/_config.yml)"
		end

		## Figure out what to do with credentials...
		# if File.exists?(@site_config['credentials'])
		# 	puts "Loading credentials from site_config location"
		# 	@credentials = YAML::load(File.open(@site_config['credentials']))
		# else
		# 	puts "You do not have a proper credentials file defined in _config.yml"
		# 	return false
		# end
	end

	def update(args={})

		#Set the sheet, default to people
		sheet    = args[:page] || 'people'

		#If set with a tab, then use that one, otherwise, default to all
		if args[:tab]
			tabs = [(site_config["sheets"][sheet]["types"].index args[:tab])+1]
		else
			tabs = (1..site_config["sheets"][sheet]["types"].length).to_a
		end

		#Now hit the web...
		key = site_config["sheets"][sheet]["key"]
		obj = site_config["sheets"][sheet]["object"] || "Default"

		tabs.each do |tab|
			tab_name = site_config["sheets"][sheet]["types"][tab-1]
			puts "\n========== Hitting Google API for: #{args[:page]}, tab: #{tab}: #{tab_name}========"

			begin
				url = URI("https://spreadsheets.google.com/feeds/list/#{key}/#{tab}/public/values?alt=json")
				data = JSON.parse(Net::HTTP.get(url))
			rescue => e
				puts "\nThe HTTP Request Failed:"
				puts "\tEnsure the document is published"
				puts "\tEnsure the headers are on row 1\n\n"
			end
			previous_data = nil
			begin
				puts "Loading previous file for comparison"
				previous_data = YAML.load( File.read("./_data/" + site_config["sheets"][sheet]["types"][tab-1] + ".yml") )
			rescue => e
				puts "WARNING: No previous data found for #{tab_name}"
			end

			results = []

			begin
				data["feed"]["entry"].each do |entry|
					this_data = {
					    filename: tab_name,
						data: entry
					}

					unless previous_data.nil?
						this_data[:previous_data] = previous_data
					end
					
					this_obj = eval("#{obj}.new(#{this_data})")
					
					this_obj.validate

					results << this_obj.format_as_yaml
				end
			rescue => e
				puts "\nSomething in parsing failed:"
				puts "\tEnsure the headers are on row 1"
				puts e
			end

			#Now results the file to YAML
			unless results.empty?
				write_yaml({
					directory: data_dir,
					filename: tab_name, 
					data: results
				})
			else
				puts "Results are empty, file not written"
			end
		end
	end

	def list_operations
		puts "\nThe following functions are available based on your configuration:"
		
		site_config['sheets'].each do |object, vals|
			if vals['types'].count > 1
				puts "\tbliss update #{object}"
				vals['types'].each do |type|
					puts "\tbliss update #{object} #{type}"
				end
			else
				puts "\tbliss update #{object}"
			end
		end
	end

	def write_yaml(args)
		directory = args[:directory]
		filename  = args[:filename]
		content   = args[:data]
		begin
			unless File.directory?(directory)
					Dir.mkdir directory
				end
			File.open(directory+'/'+filename.downcase+'.yml', 'wb') {|f|
				f.write(content.to_yaml)
			}
			puts "file: '#{directory}/#{filename.downcase}.yml' written sucessfully" 
		rescue => error
			puts "Failed to write YAML file:"
			puts error.inspect
			puts error.backtrace
		end
	end

	#This function uses the secret Amazon s3 credentials to publish the site to an s3 Bucket
	#defined in the config
	# def publish( *args )
	# 	puts "Publishing the site to: #{@credentials['production_bucket']}"	
	# 	#Require the bucket manager and make the connection, then publish
	# 	require_relative 'aws/bucket_manager'
	# 	@manager = BucketManager.new(credentials['s3_id'], credentials['s3_secret'])
 	#    	@manager.connect_to_bucket(credentials['production_bucket'])
 	#    	puts `jekyll build`
 	#  		@manager.write_directory('_site')
	# end

	# def push( *args )
	# 	puts "Preparing to Push the directory to S3"
	# 	args.flatten!
	# 	puts args
		
	# 	unless args.empty?
	# 		puts "Copying #{args[0]} to #{@credentials['push_to_bucket']}"

	# 		require_relative 'aws/bucket_manager'
	# 		@manager = BucketManager.new(credentials['s3_id'], credentials['s3_secret'])
	#     	@manager.connect_to_bucket(credentials['push_to_bucket'])
	#     	@manager.write_directory(args[0])
	# 	else
	# 		puts "Error: Need name of directory"
	#     end
 	#    end

	# def flickr(*args)
	# 	require_relative 'flickr/flickr_connect'
	# 	#Should be able to choose the set that you want here...

	# 	flickr_sets = site_config['flickr']
	# 	data_dir = site_config['data_directory']

	# 	flickr_output = {}

	# 	flickr_sets.keys.each do |flickr_set|
	# 		puts "\tProcessing #{flickr_set}"
	# 		config = {
	# 			:api_key => @credentials['flickr_api_key'],
	# 			:set => flickr_sets[flickr_set]['set']
	# 		}

	# 		flickr_manager = FlickrConnect.new(config)
	# 		flickr_manager.get_photos
	# 		flickr_output[flickr_set] = flickr_manager.photos
	# 	end
	# 	puts flickr_output
	# 	write_yaml(data_dir, 'flickr_urls', flickr_output)
	# end

end
