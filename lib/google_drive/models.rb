class GoogleSheetToYaml
	attr_accessor :filename, :previous_file
	def initialize(args)
		@filename 	   = args[:filename]
		@previous_file = args[:previous_data] || nil

		args[:data].each do |k,v|
			begin
				if k.include? "$"
					var = k.slice(4,k.length)
					instance_eval %Q{@#{var} = v["$t"]}
				end
			rescue => e
				puts $!
			end 
		end
	end

	def validate(args={})
		puts "No validate function for: #{filename}"
	end

	#Go though instance variables and write them as YAML
	def format_as_yaml
		objects = {}
		self.instance_variables.each do |k|
			objects[k.to_s.gsub('@','')] = instance_eval(k.to_s)
		end
		objects.delete("filename")
		objects.delete("previous_file")
		return objects
	end
end

class Default < GoogleSheetToYaml
	attr_accessor :name

	def validate(args={})
		puts name
	end
end

class Person < GoogleSheetToYaml
	attr_accessor :name, :picture, :role, :bio, :gscholarlink, :interests, :affiliation, :url 
	@@profile_photo_path = "./assets/auto_generated/profile_pics"
	
	def scrape_google_scholar(gscholar_url)
		puts "Going to Google Scholar: #{gscholar_url}"
		print "Scraping..."
		require 'nokogiri'
		require 'open-uri'
		doc_html = Nokogiri::HTML(open(gscholar_url))
		# puts doc_html

		if picture.nil? or picture == ""
			get_photo(doc_html)
		end

		if url.nil? or url == ""
			get_url(doc_html)
		end

		if interests.nil? or interests == ""
			get_interests(doc_html)
		end

		if affiliation.nil? or affiliation == ""
			get_affiliation(doc_html)
		end
		puts "done.\n\n"
	end

	def get_photo(doc_html)
		print "photo..."
		begin
			photo_url = doc_html.xpath("//*[@id='gsc_prf_pup']//@src")[0].to_s

			if photo_url =~ /^\//i
				photo_url.insert(0,'http://scholar.google.com')
			end

			unless Dir.exists? @@profile_photo_path
				Dir.mkdir(@@profile_photo_path)
			end

			open(photo_url) {|f|
	   			File.open("#{@@profile_photo_path}/#{name.gsub(/\s+/,'_')}.jpg","wb") do |pic|
	    			pic.puts f.read
	   			end
			}

			@picture = "#{@@profile_photo_path}/#{name.gsub(/\s+/,'_')}.jpg"[1..-1]
		rescue => e
			puts "Oh no, an error occured, Google Scholar may have changed their page layout"
			puts $!
		end
	end

	def get_affiliation(doc_html)
		print "affiliation..."
		begin
			# return doc_html.xpath("//div[contains(@class,'g-unit')]//span[contains(@id,'cit-affiliation-display')]/text()")[0].to_s
			items = doc_html.xpath("//*[@class='gsc_prf_il']")
			@affiliation = items[0].text
		rescue => e
			puts "Oh no, an error occured, Google Scholar may have changed their page layout"
			puts $!
		end
	end

	def get_interests(doc_html)
		print "interests..."
		begin
			items = doc_html.xpath("//*[@class='gsc_prf_il']")

			interests_array = []

			items[1].children.each do |child|
				unless child.text =~ /\s*,\s*/i
					interests_array << child.text
				end
			end
			unless interests_array.empty?
				@interests = interests_array.join(', ')
			end
		rescue => e
			puts "Oh no, an error occured, Google Scholar may have changed their page layout"
			puts $!
		end
	end

	def get_url(doc_html)
		print "url..."
		begin
			items = doc_html.xpath("//*[@class='gsc_prf_il']")
			url = nil || items[2]
			unless url.children[1].nil?
				@url = url.children[1].attributes["href"].to_s
			end
		rescue => e
			puts "Oh no, an error occured, Google Scholar may have changed their page layout"
			puts $!
		end
	end

	def validate(args={})
		begin
			puts "Validating: #{ self.name }"
			unless gscholarlink == "" or gscholarlink.nil? or args[:gscholar]=='false'
				scrape_google_scholar(gscholarlink)
			end
		rescue => e
			puts "Error on #{self.name}!"
		end
	end
end

class Publication < GoogleSheetToYaml
	attr_accessor :name, :authors, :year, :downloadlink, :title, :etc, :category, :abstract										

	def validate(args={})
		puts "Validating: #{self.name}"
	end

	def get_categories
		if @category
			@category = @category.split(',').collect!{|cat| cat.strip }
		end
		print @category
	end
end

class Press < GoogleSheetToYaml
	attr_accessor :name, :year

	def validate(args={})
		puts "Article: #{name[0..45]}..."
	end
end

class Course < GoogleSheetToYaml
	attr_accessor :name, :number, :url, :credits, :description																		

	def validate(args={})
		puts "#{number}: #{name}"
	end
end

class LabGroup < GoogleSheetToYaml

end