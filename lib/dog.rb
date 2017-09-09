class Dog
	attr_accessor :name, :breed
	attr_reader :id

	def initialize(name:, breed:, id:nil)
		@name=name
		@breed=breed
		@id=id
	end

	def self.create_table
		DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE dogs")
	end

	def save
		if @id
			self.update
		else
			sql="INSERT INTO dogs(name, breed) VALUES(?,?)"
			DB[:conn].execute(sql, @name, @breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		end

	end

	def update
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
		DB[:conn].execute(sql, @name, @breed, @id)
	end

	def self.create(name:, breed:, id:nil)
		new_dog = self.new(name:name, breed:breed, id:id)
		new_dog.save
		new_dog
	end

	def self.find_by_id(id)
		row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ? LIMIT 1", id)[0]
		#binding.pry
		self.new(name:row[1], breed:row[2], id:row[0])
	end

	def self.find_or_create_by(name:, breed:)
		exists = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed).flatten
		return self.find_by_id(exists[0]) if (exists.size > 0) 
		self.create(name:name, breed:breed)
	end

	def self.new_from_db(row)
		self.new(name:row[1], breed:row[2], id:row[0])
	end

	def self.find_by_name(name)
		row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0]
		self.new_from_db(row)
	end

end