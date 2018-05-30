class Dog
	attr_accessor :name, :breed
	attr_reader :id

	def initialize(id: nil, name:, breed:)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		sql = <<-SQL
		CREATE TABLE IF NOT EXISTS dogs (
		id INTEGER PRIMARY KEY,
		name TEXT,
		breed TEXT
		)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = "DROP TABLE IF EXISTS dogs"
		DB[:conn].execute(sql)
	end

	def save
		if self.id != nil
			self.update
		else
			sql = <<-SQL
				INSERT INTO dogs (name, breed)
				VALUES (?,?)
			SQL
			DB[:conn].execute(sql, name, breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
			self
		end
	end
	def self.create(dog_hash)
		self.new(name: nil, breed: nil).tap do |attribute|
			dog_hash.each do |key, value|
				attribute.send("#{key}:", value)
			end
			dog.save
		end
	end
	def self.create(attributes_hash)
    self.new(name: nil, breed: nil).tap do |dog|
      attributes_hash.each do |key, value|
        dog.send("#{key}=", value)
      end
      dog.save
    end
  end

	def self.find_by_id(id)
		sql = "SELECT * FROM dogs WHERE id = ?"
		dog = (DB[:conn].execute(sql, id)).flatten
		dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
	end

	def self.find_or_create_by(name: name, breed: breed)
		#when creating a new dog with the same name as persisted dogs, it #returns the correct dog
		dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND BREED = ?", name, breed).flatten
		#binding.pry
		if !dog.empty?
			dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
		else
			dog = self.create(name: name, breed: breed)
		end
		dog
	end

	def self.new_from_db(dog_array)
		#creates an instance with corresponding attribute values
		dog = Dog.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
	end

	def self.find_by_name(name)
		#returns an instance of dog that matches the name from the DB
		sql = "SELECT * FROM dogs WHERE name = ?"
		dog_array = (DB[:conn].execute(sql, name)).flatten
		dog = Dog.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
	end

	def update
		#update updates the record associated with a given instance
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
		DB[:conn].execute(sql, self.name, self.breed, self.id)
 	end
end
