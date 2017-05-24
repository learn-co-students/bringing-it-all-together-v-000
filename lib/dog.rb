class Dog

	attr_accessor :name, :breed, :id

	def initialize(id = nil, attributes)
		@id = id
		attributes.each do |key, value|
			self.send("#{key}=", value)
		end
	end	

	def self.create_table
		sql =<<-SQL 
			CREATE TABLE IF NOT EXISTS dogs(
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXt);
			SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE dogs")
	end

	def save
		sql =<<-SQL
				INSERT INTO dogs (name, breed)
				VALUES (?, ?)
				SQL
		DB[:conn].execute(sql, self.name, self.breed)

		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end

	def self.create(attributes)
		Dog.new(attributes).tap do |dog|
			dog.save
		end
	end

	def self.find_by_id(id)
		sql =<<-SQL
				SELECT * 
				FROM dogs
				WHERE id = ?
				SQL

		 self.new_from_db(DB[:conn].execute(sql, id).flatten)
	end

	def self.find_or_create_by(name:, breed:)
		dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
		if !dog.empty?
			current_dog = Dog.new(dog[0], name: dog[1], breed: dog[2])
		else
			current_dog = Dog.create(name: name, breed: breed)
		end
		current_dog
	end

	def self.new_from_db(row)
		self.new(row[0], name: row[1], breed: row[2])
	end

	def self.find_by_name(name)
		sql =<<-SQL
				SELECT * 
				FROM dogs
				WHERE name = ?
				SQL

		 self.new_from_db(DB[:conn].execute(sql, name).flatten)
	end

	def update
		sql =<<-SQL 
				UPDATE dogs 
				SET name = ?, breed = ?
				WHERE id = ?
				SQL

		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end
end