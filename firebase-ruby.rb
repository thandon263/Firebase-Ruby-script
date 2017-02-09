require 'brewery_db'
require 'firebase'

# connect to firebase
firebase_uri = 'https://screencast-3a4b3.firebaseio.com/'
@firebase = Firebase::Client.new(firebase_uri)

# connect to BreweryDB
@brewery_db = BreweryDB::Client.new do |config|
	config.api_key = 'aacd7c4cfc01bf6a434c4cb71b82e4c8'
end

def search_breweries(search_term)
	@hash = Hash.new
	breweries = @brewery_db.search.breweries(q: search_term)

	if breweries.count < 1
		puts "No breweries found named #{search_term}"
		exit
	else
		breweries.each_with_index do |b, index|
			index += 1
			@hash[index] = b.name
			puts index.to_s + "-" + b.name
		end
	end
end

def db_save(search_term)
	response = @firebase.push("favourite_breweries", {
		name: @hash[search_term.to_i].to_s,})
	if response.success?
		puts @hash[search_term.to_i].to_s + "Successfully saved to the database."
	else
		puts "I\'m sorry an error occured saving to the databse."
	end
end

def get_favourite_breweries
	favourites = @firebase.get("favourite_breweries")
	parsed = JSON.parse(favourites.raw_body)

	parsed.each do |p|
		puts p[1]['name']
	end
end



# Prompt for search term
puts "Enter a Search Term: "
search_term = gets.chomp
search_breweries search_term

puts "Enter the number of the brewery you would like to save."
search_term = gets.chomp
db_save(search_term)
get_favourite_breweries


