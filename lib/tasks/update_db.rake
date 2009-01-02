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
		no_isbn = 0
		weve_already_got_one = 0
		found = 0
		not_found = 0
		Book.find(:all).each do |book|
			# we key cover filenames off ISBNs, chances are if we don't have an
			# ISBN there won't be an image
			if not book.isbn or book.isbn.empty?
				no_isbn += 1
				next
			end

			# don't refetch images that we already have
			if book.has_cover_image?
				puts "already have image for #{book.isbn}."
				weve_already_got_one += 1
				next
			end

			print "fetching cover image for #{book.isbn}... "

			url = book.fetch_cover_image

			if url
				puts "found!"
				found += 1
			else
				puts "not found."
				not_found += 1
			end

			sleep GOOGLE_DELAY
		end

		total = no_isbn + weve_already_got_one + found + not_found
		puts "done looking up covers for #{total} books."
		puts "#{weve_already_got_one} already had cover images"
		puts "#{no_isbn} had no ISBN"
		puts "got #{found} new images, couldn't find #{not_found}"
	end

	desc "Attempt to fetch Library of Congress ids for books that don't have them."
	task :loc do
		# XXX to be written...
	end
end
