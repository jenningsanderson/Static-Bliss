require_relative 'lib/Static-Bliss'

#Initialize the environment by loading the configuration files

if File.exists?('_config.yml')
	puts "Loading site_config from _config.yml"
	SITE_CONFIG = YAML::load(File.open('_config.yml'))
else
	puts "Entering test environment, _config.yml does not exist"
	SITE_CONFIG = YAML::load(File.open('spec/_config.yml'))
end

if File.exists?(SITE_CONFIG['credentials'])
	puts "Loading credentials from site_config location"
	CREDENTIALS = YAML::load(File.open(SITE_CONFIG['credentials']))
else
	puts "You do not have a proper credentials file defined in _config.yml"
end

#Now create the appropriate connections
publisher = BucketManager.new(CREDENTIALS['s3_id'], CREDENTIALS['s3_secret'])
g_drive   = GoogleDriveYAMLParser.new(CREDENTIALS['google_username'], CREDENTIALS['google_password'])



#Start the rake tasks here
desc "Build and publish the entire website"
task :publish do

	puts "Connecting to bucket"

	publisher.connect_to_bucket(credentials['production_bucket'])
	
  	`jekyll build --destination _to_upload`
  	
  	publisher.write_directory('_to_upload')
 end



#My favorite piece of metaprogramming:
namespace :update do
	SITE_CONFIG['google_info'].each do |symbol, data|
		eval %Q{
			if data["types"].length == 1
				desc "Updates the #{data["types"][0]} page from Google Drive data"
				task data["types"][0].to_sym, :arg1 do |task, args|
					update_page(symbol, data["types"][0], args)
				end

			else
				namespace symbol.to_sym do
					data["types"].each do |data_type|
						desc "Updates the #{symbol} page for only specified #{symbol}"
						task data_type.gsub(/\s+/,'_').to_sym, :arg1 do |t, args|
							update_page(symbol, data_type, args)
						end
					end
					desc "Update all #{symbol} from Google Drive"
					task :all, :arg1 do |task, args|
						Rake.application.tasks.each do |task_name|
  							unless task_name.name.to_s =~ /:all$/
    							task_name.invoke(args[:arg1]) if task_name.name =~ /^update:(#{symbol})/
    						end
    					end
					end
				end
			end
		}
	end #End data iterator

	desc "Run every update task"
	task :all, :arg1 do |task, args|
  		Rake.application.tasks.each do |t|
  			unless t.name.to_s =~ /:all$/
    			t.invoke(args[:arg1]) if t.name =~ /^update:/
    		end
    	end
  	end
end #End namespace