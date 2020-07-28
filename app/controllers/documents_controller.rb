require 'tokyocabinet'
include TokyoCabinet
class DocumentsController < ApplicationController
	before_filter :create_db_instance ,  except: :current_time_stamp 
	after_filter :close_db ,  except: :current_time_stamp 

	def index
		time = Time.now.getutc
		@table.iterinit
		@documents = []
		while key = @table.iternext
  			value = @table.get(key)
  			if value
    			@documents << value
  			end
		end  
		render json: {
			documents: @documents
		}
	end	

	def show
		pkey = params["id"]
		document = @table.get(pkey)
		if document
  			render :json => {
  				"document" => document
  				 }
  		else	
  			ecode = @table.ecode
  			render json: {
  				status: 500,
  				error: @table.errmsg(ecode)
  			}
		end
	end	



	def create	
		
		pkey = @table.genuid
		time_now = current_time_stamp
		params["document"].merge!({ "created_at" =>  time_now.to_s, "updated_at" => time_now.to_s})
		if @table.put(pkey, params["document"])
  			render :json => {
  				"document" => @table.get(pkey),
  				"status" => :created,
  				"id" => pkey
  			}
  			@table.close()
  		else	
  			ecode = @table.ecode
  			render json: {
  				error: @table.errmsg(ecode)
  			}
		end

	end	

	def update

		pkey = params["id"]

		document = @table.get(pkey)
		params["document"].merge!({"created_at" =>  document["created_at"], "updated_at" => current_time_stamp.to_s})
		if @table.put(pkey, params["document"])
  			render :json => {
  				"document" => @table.get(pkey),
  				"status" => :updated,
  				"id" => pkey
  			}
  		else	
  			ecode = @table.ecode
  			render json: {
  				status: 400,
  				error: @table.errmsg(ecode)
  			}
		end



	end
	
	def destroy
		if @table.out(params["id"])
			render json: {
				message: "record deleted sucessfully"
			}
		else

			render json: {
				error: @table.errmsg(@table.ecode)
			}
		end	


	end	


	def current_time_stamp
		Time.now.getutc
	end	

	def close_db
		@table.close()
	end	

	def create_db_instance
		@table = TDB::new
		path = "#{Rails.root}/db/tokyocabinet/documents.tch"
		if !@table.open(path, TDB::OWRITER | TDB::OCREAT)
  			ecode = @table.ecode
  			
		end
	end	
end	