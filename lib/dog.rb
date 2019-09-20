class Dog
	attr_accessor :name, :breed, :id

	def initialize(name:, breed:, id: nil)
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
		sql = <<-SQL
			DROP TABLE dogs
		SQL

		DB[:conn].execute(sql)
	end

	def save
		# if self.id
  #   	self.update
  # 	else

			sql = <<-SQL
				INSERT INTO dogs (name, breed) VALUES (?,?)
			SQL

			DB[:conn].execute(sql, self.name, self.breed)
			self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end

	def self.create(attr_hash)
		dog = Dog.new(name: attr_hash[:"name"], breed: attr_hash[:"breed"])
		dog.save
		dog
	end

	def self.new_from_db(row)
		dog = Dog.new(id: row[0], name: row[1], breed: row[2])
		dog
	end

	def self.find_by_id(id)
		sql = <<-SQL
				SELECT * FROM dogs WHERE id = ?
			SQL

		row = DB[:conn].execute(sql, id)[0]
		dog = Dog.new(name: row[1], breed: row[2], id: row[0])
		dog
	end

	def self.find_or_create_by(attr_hash)
		sql = <<-SQL
				SELECT * FROM dogs WHERE name = ? AND breed = ?
			SQL

		row = DB[:conn].execute(sql, attr_hash[:"name"], attr_hash[:"breed"])[0]
		if row
			self.new_from_db(row)
		else
			self.create(attr_hash)
		end

	end

	def self.find_by_name(name)
		sql = <<-SQL
				SELECT * FROM dogs WHERE name = ?
			SQL

		row = DB[:conn].execute(sql, name)[0]
		self.new_from_db(row)
	end

	def update
		sql = <<-SQL
				UPDATE dogs SET name = ?, breed = ?
				WHERE id = ?
			SQL

		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

	

end