# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def clean(input)
		# XXX change this to a more fine-grained cleanup of the input and then untain the string
		return h(input)
	end
end
