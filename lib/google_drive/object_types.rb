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

	def validate(params, previous_data)
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


	def validate(params, previous_data)
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

	def validate(params, previous_data)
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

	def validate(params, previous_data)
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

	def validate(param, previous_data)
		if @gscholar_link
			if param[0]=='gscholar'
				print "Scraping Google Scholar..."
				scrape_google_scholar(@gscholar_link)
				print "done\n"
			elsif not previous_data.empty?
				puts "User has google scholar credentials, using last scraped instance, consider adding 'gscholar' argument to update from google"
				merge_previous_data(previous_data)
			end
		end
	end

	def merge_previous_data(previous_data)
		previous_data.each do |key, value|
			if (instance_eval "@#{key}").nil?
				instance_eval "@#{key} = value"
			end
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
		begin
			photo_url = doc_html.xpath("//*[@id='gsc_prf_pup']//@src")[0].to_s

			if photo_url =~ /^\//i
				photo_url.insert(0,'http://scholar.google.com')
			end

			open(photo_url) {|f|
	   			File.open("#{@@profile_photo_path}/#{@name.gsub(/\s+/,'_')}.jpg","wb") do |pic|
	    			pic.puts f.read
	   			end
			}

			return "#{@@profile_photo_path}/#{@name.gsub(/\s+/,'_')}.jpg"[1..-1]
		
		rescue => e
			puts "Oh no, an error occured, Google Scholar may have changed their page layout"
			puts $!
		end
	end

	def get_affiliation(doc_html)
		begin
			# return doc_html.xpath("//div[contains(@class,'g-unit')]//span[contains(@id,'cit-affiliation-display')]/text()")[0].to_s
			items = doc_html.xpath("//*[@class='gsc_prf_il']")
			affiliation = items[0]

			return affiliation.text
		rescue => e
			puts "Oh no, an error occured, Google Scholar may have changed their page layout"
			puts $!
		end
	end

	def get_interests(doc_html)
		begin 

			items = doc_html.xpath("//*[@class='gsc_prf_il']")
			interests = items[1]

			interests_array = []

			interests.children.each do |child|
				unless child.text =~ /\s*,\s*/i
					interests_array << child.text
				end
			end
			return interests_array.join(', ')
		rescue => e
			puts "Oh no, an error occured, Google Scholar may have changed their page layout"
			puts $!
		end
	end

	def get_url(doc_html)
		begin
			items = doc_html.xpath("//*[@class='gsc_prf_il']")
			url = nil || items[2]
			unless url.children[1].nil?
				return url.children[1].attributes["href"].to_s
			else
				return ""
			end
		rescue => e
			puts "Oh no, an error occured, Google Scholar may have changed their page layout"
			puts $!
		end
	end

end