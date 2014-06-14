'''
Each of these classes represents an object type that may be pulled dynamically from
Google Drive.  Each of these objects accepts a validation argument to perform further
operations
'''

#The course is currently implemented for the Human-Centered-Computing Site
class Course
	attr_accessor :name, :type
	def initialize(name, type)
		@name = name
		@type = type
		puts "Name: #{@name}"
	end

	def validate(params)
		return nil
	end
end

#Publications: 
class Publication
	attr_accessor :name, :type
	def initialize(name, type)
		@name = name
		@type = type
		puts "Publication: #{name}"
	end


	def validate(params)
		get_categories
	end

	def get_categories
		if @category
			@category = @category.split(',').collect!{|cat| cat.strip }
		end
		print @category
	end
end

class Press
	attr_accessor :name
	def initialize(name, role)
		@name = name
		puts "Article: #{name[0..45]}..."
	end

	def validate(params)
		return nil
	end

end

class Project
	attr_accessor :name, :type
	def initialize(name, type)
		@name = name
		@type = type
		puts "Project Name: #{@name}"
	end

	def validate(params)
		return nil
	end
end











#This is the toughest one -- needs some work, we'll see what happens
class Person
	@@profile_photo_path = "./assets/auto_generated/profile_pics"

	attr_accessor :name, :status
	def initialize(name, status)
		@name = name
		@status = status
		puts "Name: #{@name}"
	end

	def validate(param)
		if @gscholar_link and param[:arg1]=='gscholar'
			print "Scraping Google Scholar..."
			scrape_google_scholar(@gscholar_link)
			print "done\n"
		end
	end

	def scrape_google_scholar(url)
		require 'nokogiri'
		require 'open-uri'
		doc_html = Nokogiri::HTML(open(url))

		unless @picture
			@picture = get_photo(doc_html)
		end

		unless @url
			@url = get_url(doc_html)
		end

		unless @interests
			@interests = get_interests(doc_html)
		end

		unless @affiliation
			@affiliation = get_affiliation(doc_html)
		end
	end

	def get_photo(doc_html)
		photo_url = doc_html.xpath("//div[contains(@class,'g-unit')]//div[contains(@class,'cit-user-info')]//img/@src")[0].to_s

		if photo_url =~ /^\//i
			photo_url.insert(0,'http://scholar.google.com')
		end

		open(photo_url) {|f|
   			File.open("#{@@profile_photo_path}/#{@name.gsub(/\s+/,'_')}.jpg","wb") do |pic|
    			pic.puts f.read
   			end
		}

		return "#{@@profile_photo_path}/#{@name.gsub(/\s+/,'_')}.jpg"[1..-1]
	end

	def get_affiliation(doc_html)

		doc_html.xpath("//div[contains(@class,'g-unit')]//span[contains(@id,'cit-affiliation-display')]/text()")[0].to_s
	end

	def get_interests(doc_html)
		interests_html = doc_html.xpath("//div[contains(@class,'g-unit')]//span[contains(@id,'cit-int-read')]//a/text()")

		interests = [ ]
		interests_html.each do |interest|
			interests << interest.to_s
		end

		return interests.join(', ')
	end

	def get_url(doc_html)
		doc_html.xpath("//div[contains(@class,'g-unit')]//span[contains(@id,'cit-homepage-read')]//a/@href")[0].to_s
	end

	# local_variables.each do |var|
	# 	unless var.to_s =~ /(_html$|_url$)/i
	# 		unless eval(var.to_s).empty?
	# 			instance_variable_set("@#{var}", eval(var.to_s))
	# 		end
	# 	end
	# end

end