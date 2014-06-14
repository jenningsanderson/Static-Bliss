require_relative 'lib/Static-Bliss'

desc "Build and publish the entire website"
task :publish do
	puts "Need to find a way to properly authenticate here"
end

GDrive = GoogleDriveYAMLParser.new(username="cuprojectepic@gmail.com",password="CrisisInformatics2014")

#My favorite piece of metaprogramming:
namespace :update do
	GDrive.google_drive_data.each do |symbol, data|
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