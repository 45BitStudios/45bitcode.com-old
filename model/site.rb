require 'mongo'
require 'mongoid'
require 'json/ext' 

class Site

	include Mongoid::Document
	include Mongoid::Timestamps
	field :host_name, type: String
	field :name, type: String
	field :title, type: String
	field :description, type: String 
	field :facebook, type: String 
	field :twitter, type: String 
	field :instagram, type: String 
	field :email, type: String 
	field :author, type: String 
	field :phone, type: String
	field :city_st_zip, type: String 
	field :author_link, type: String 
	field :company, type: String 
	field :img_url, type: String 
	field :fb_admin, type: String 
	field :favicon, type: String 
	field :city_st_zip2, type: String 
	field :url, type: String 
	field :tw_id, type: String 
	field :tumblr, type: String 
end