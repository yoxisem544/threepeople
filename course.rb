require 'json'

class Course

	attr_accessor :book_name, :series, :isbn13, :another_book_name, :author, :page_covering, :edition, :size, :publish_store, :publish_date
	def initialize(h)
		@attributes = [:book_name, :series, :isbn13, :another_book_name, :author, :page_covering, :edition, :size, :publish_store, :publish_date]
    h.each {|k, v| send("#{k}=",v)}
	end

	def to_hash
		@data = Hash[ @attributes.map {|d| [d.to_s, self.instance_variable_get('@'+d.to_s)]} ]
	end

	def to_json
		JSON.pretty_generate @data
	end
end
