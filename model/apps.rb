require 'mongo'
require 'mongoid'
require 'json/ext' 

class App

	include Mongoid::Document
	include Mongoid::Timestamps
	field :name, type: String
	
end