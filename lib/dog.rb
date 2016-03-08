class Dog
	attr_accessor :name,:breed , :id

	def initialize(id=nil,arg)
		@name = arg[:name]
		@breed = arg[:breed]
		@id = id
	end 


	def self.create_table
		sql = <<-SQL 
			CREATE TABLE IF NOT EXISTS Dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT)
		 SQL
   		 DB[:conn].execute(sql) 
	end

	def self.drop_table
		sql = <<-SQL 
			DROP TABLE dogs
		 SQL
   		 DB[:conn].execute(sql) 
	end

	def save
		if self.id
     		 self.update
   		else
	  	    sql =  <<-SQL 
	      		INSERT INTO dogs (name,breed)
	      		VALUES (?,?)
	        SQL
	        DB[:conn].execute(sql, self.name, self.breed)
	         @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
   		end
	end

	def self.create(arg)
		dog = self.new(arg)
		dog.save
		dog
	end

	def self.find_by_id(id)
		sql = "SELECT * FROM dogs WHERE id = ?"
    	result = DB[:conn].execute(sql, id)[0]
    	self.new(id,{name:result[0],breed:result[1]})	
	end

	def self.find_or_create_by(arg)
		sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    	result = DB[:conn].execute(sql,arg[:name],arg[:breed])[0]	
    	if result
    		return dog = self.new(result[0],{name:result[1],breed:result[2]})
    	else
    		return self.create(arg)
    	end
	end

	def self.new_from_db(row)
      new_dog = self.new(row[0],{name:row[1],breed:row[2]})
      new_dog
    end

    def self.find_by_name(name)
    	sql = "SELECT * FROM dogs WHERE name = ?"
    	result = DB[:conn].execute(sql, name)[0]
    	self.new(result[0],{name:result[1],breed:result[2]})		
    end

   def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed,self.id)
  end



end