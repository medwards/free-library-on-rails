# tasks for checking for new data on the books in our database and updating
# them.
#
# these can be very hard on the servers we're getting the data from (depending
# on how many books you have), so be gentle. don't run them too often.

# number of seconds to delay between requests to Google Books
GOOGLE_DELAY=1

namespace :update do
	desc "Attempt to fetch cover images for books that don't have them."
	task :covers => :environment do
		Book.find(:all).each do |book|
			# we key cover filenames off ISBNs, chances are if we don't have an
			# ISBN there won't be an image
			next unless book.isbn

			# don't refetch images that we already have
			if book.has_cover_image?
				puts "already have image for #{book.isbn}."
				next
			end

			print "fetching cover image for #{book.isbn}... "

			url = book.fetch_cover_image

			if url
				puts "found!"
			else
				puts "not found."
			end

			sleep GOOGLE_DELAY
		end
	end

	desc "Attempt to fetch Library of Congress ids for books that don't have them."
	task :loc do
		# XXX to be written...
	end
end
