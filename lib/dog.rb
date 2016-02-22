class Dog

	attr_accessor :name, :breed
	attr_reader :id

	def initialize(id = nil, x)
		@id = id
		@name = x[:name]
		@breed = x[:breed]
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs(
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT
				)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute("drop table dogs")
	end

	def self.new_from_db(row)
		x = {name: row[1], breed: row[2]}
		dog = self.new(row[0], x)
	end

	def update
		sql = <<-SQL
			UPDATE dogs WHERE id = ?
			SET name = ?, breed = ?
		SQL
		DB[:conn].execute(sql, self.id, self.name, self.breed)
	end

	def self.find_by_id(id)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE id = ?
		SQL

		row = DB[:conn].execute(sql, id)[0]
		dog = self.new_from_db(row)
		dog
	end

	def self.find_or_create_by(x)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ? AND breed = ?
		SQL
		db = DB[:conn].execute(sql, x[:name], x[:breed])
	
		if db != []
			self.find_by_name(x[:name])
		else
			self.create(x)
		end
	end

	def save
		sql = <<-SQL
			INSERT INTO dogs (name, breed)
			VALUES (?,?)
		SQL
		DB[:conn].execute(sql, self.name, self.breed)
		@id = DB[:conn].execute("select last_insert_rowid() FROM dogs")[0][0]
	end

	def self.create(x)
		dog = Dog.new(x)
		dog.save
		dog
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * from dogs
			WHERE name = ?
		SQL

		row = DB[:conn].execute(sql,name)[0]
		dog = self.new_from_db(row)
		dog
	end

	def self.find_by_breed(breed)
		sql = <<-SQL
			SELECT * from dogs
			WHERE breed = ?
		SQL

		row = DB[:conn].execute(sql,breed)[0]
		dog = self.new_from_db(row)
		dog
	end

















end