require 'pry'

class Dog
	attr_accessor :name, :breed, :id, :db

	def initialize(id: nil, name:, breed:)
		@name = name
		@breed = breed
		@id = id
	end
#binding.pry
	def self.drop_table
		DB[:conn].execute('DROP TABLE IF EXISTS dogs')
	end
	
	def self.create_table
		self.drop_table
		sql = <<-SQL 
		CREATE TABLE dogs (
		id INTEGER PRIMARY KEY,
		name TEXT,
		breed TEXT
		)
		SQL

		DB[:conn].execute(sql)
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL
			INSERT INTO dogs (name, breed) VALUES (?, ?)
			SQL

			DB[:conn].execute(sql, self.name, self.breed)

			@id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
		end
		self
	end

	def self.create(row)

		name = row[:name]
		breed = row[:breed]
		dog = self.new(name:name, breed:breed)
		dog.save
	end

	def self.new_from_db(row)
		
		id = row[0]
		name = row[1]
		breed = row[2]
		dog = self.new(id:id, name:name, breed:breed)
	end

	def self.find_by_id(id)
		sql = <<-SQL
		SELECT * FROM dogs Where id = ?
		SQL

		row = DB[:conn].execute(sql, id).flatten
		dog = self.new_from_db(row)
	end

	def self.find_by_name(name)
		sql = <<-SQL
		SELECT * FROM dogs Where name = ?
		SQL

		row = DB[:conn].execute(sql, name).flatten
		dog = self.new_from_db(row)
	end

	def self.find_or_create_by(id: nil, name: nil, breed: nil)
		sql = <<-SQL
		SELECT * FROM dogs Where name = ? AND breed = ?
		SQL

		row = DB[:conn].execute(sql, name, breed).flatten
		
		if row == []
			dog = Dog.new(name:name, breed:breed).save	
		else
			dog = self.new_from_db(row)
		end
	end

	def update
		sql = <<-SQL
  		UPDATE dogs set name = ?, breed = ? WHERE id = ?
  		SQL

  		DB[:conn].execute(sql, self.name, self.breed, self.id)
  	
  		self
	end

	
end