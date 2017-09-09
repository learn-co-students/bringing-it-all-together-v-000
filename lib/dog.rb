require 'pry'

class Dog

	attr_accessor :name, :breed, :id

	def initialize(hash)
		@name = hash[:name]
		@breed = hash[:breed]
		@id = nil
	end


	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
			DROP TABLE IF EXISTS dogs;
		SQL
		DB[:conn].execute(sql)
	end

	def save
		sql = <<-SQL
			INSERT INTO dogs (name, breed) VALUES (?, ?);		
		SQL
		DB[:conn].execute(sql, @name, @breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
	end

	def self.create(hash)
		dog = self.new(hash)
		dog.save
		dog
	end

	def self.find_by_id(id)
		sql = <<-SQL
			SELECT * FROM dogs WHERE id = ? LIMIT 1;
		SQL
		dog_values = DB[:conn].execute(sql, id)
		dog_hash = {name: dog_values[0][1], breed: dog_values[0][2]}
		dog = self.new(dog_hash)
		dog.id = id
		dog
	end

	def self.find_or_create_by(hash)
		sql = <<-SQL
			SELECT * FROM dogs WHERE name = ? and breed = ?;
		SQL
		dogs = DB[:conn].execute(sql, hash[:name], hash[:breed])
		if dogs.empty?
			dog = self.create(hash)
		else
			dog = self.new({name: dogs[0][1], breed: dogs[0][2]})
			dog.id = dogs[0][0]
		end
		dog
	end

	def self.new_from_db(input)
		dog = self.new({name: input[1], breed: input[2]})
		dog.id = input[0]
		dog
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM dogs WHERE name = ? LIMIT 1;
		SQL
		output = DB[:conn].execute(sql, name)
		self.new_from_db(output[0])
	end

end
