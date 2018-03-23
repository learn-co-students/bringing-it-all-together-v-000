require 'pry'
class Dog 
	attr_accessor :name, :breed, :id

	def initialize(name:, breed:, id: nil)
		@name = name 
		@breed = breed 
		@id = id
	end

	def self.create_table 
		sql = <<-SQL
			CREATE TABLE dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT);
		SQL
	end

	def self.drop_table 
		sql = <<-SQL
			DROP TABLE dogs;
		SQL

		DB[:conn].execute(sql)
	end

	def save
		sql = <<-SQL
			INSERT INTO dogs (name, breed) VALUES (?, ?)
		SQL
		DB[:conn].execute(sql, self.name, self.breed)

		self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end

	def self.new_from_db(row)
		id = row[0]
		name = row[1]
		breed = row[2]
		dog = self.new(name: name, breed: breed, id: id)
		end

	def self.create(attributes)
		dog = self.new(attributes)
		dog.save
		dog
	end

	def self.find_by_id(id)
		sql = <<-SQL
			SELECT * FROM dogs WHERE id = ?
		SQL

		dog = DB[:conn].execute(sql, id)[0]
		# binding.pry
		dog = new_from_db(dog)
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM dogs WHERE name = ?
		SQL
		dog = DB[:conn].execute(sql, name)[0]
		dog = new_from_db(dog)
	end

	def update 
		sql = <<-SQL
			UPDATE dogs SET name = ?, breed = ? WHERE id = ?
		SQL
		DB[:conn].execute(sql, self.name, self.breed, self.id )
	end

	def self.find_or_create_by(name:, breed: )
		dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
		if !dog.empty?
			dog_data = dog[0]
			dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
		else 
			dog = self.create(name: name, breed: breed)
		end
		dog
	end

end
	