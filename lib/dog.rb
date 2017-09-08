require 'pry'
class Dog
	attr_accessor :id, :name, :breed

	def initialize(hash)
		@name = hash[:name]
		@breed = hash[:breed]
		@id = hash[:id]
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs
			(id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE dogs")
	end

	def save
		if !!self.id
			self.update
		else
			sql = <<-SQL
				INSERT INTO dogs (name, breed)
				values (?, ?)
			SQL
			DB[:conn].execute(sql, self.name, self.breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
			self
		end
	end

	def self.create(hash)
		dog = Dog.new(hash)
		dog.save
	end

	def self.find_by_id(some_id)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE id = ?
		SQL
		dog_data = DB[:conn].execute(sql, some_id).flatten
		dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
		dog
	end

	def self.find_or_create_by(hash)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ? AND breed = ?
		SQL
		found = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten

		if !!found[0]
			self.find_by_id(found[0])
		else
			self.create(hash)
		end
	end

	def self.new_from_db(row)
		Dog.new(id: row[0], name: row[1], breed: row[2])
	end

	def self.find_by_name(my_name)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ?
		SQL

		row = DB[:conn].execute(sql, my_name).flatten
		self.new_from_db(row)
	end

	def update
		sql = <<-SQL
			UPDATE dogs
			SET name = ?, breed = ?
			WHERE id =?
		SQL
		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end
end