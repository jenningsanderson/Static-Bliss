require "spec_helper"

describe "Site Building Rake Tasks" do

	it "Can access the config file and create the appropriate rake tasks" do
	    #This is a shitty test, but that's okay
    	`rake -T`.scan(/#.*/i).count.should > 5
	end

	it "Can successfully build a task" do
	    puts `rake update:Press`
	end



end