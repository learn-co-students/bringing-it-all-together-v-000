class Dog

	attr_accessor :name, :breed, :id

	def initialize(attrs)
		attrs.each {|attr, value| self.send(("#{attr}="), value)}
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT
			);
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
			update.self
		else
			sql = <<-SQL
				INSERT INTO dogs 
				(name, breed)
				VALUES (?, ?)
			SQL

			DB[:conn].execute(sql, self.name, self.breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		end
		self
	end

	def self.create(attr_hash)
		new_pupper = Dog.new(attr_hash)
		new_pupper.save
		new_pupper
	end

	def self.find_by_id(id)
		# dog_hash = {}
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE id = (?)
		SQL
		dog_arr = DB[:conn].execute(sql, id).flatten
		Dog.new_from_db(dog_arr)
		# Dog.new(dog_hash)
	end

	def self.find_or_create_by(attr_hash)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ? AND breed = ?
		SQL
		dog = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed]).flatten
		if dog.empty?
			#create and save new pupper in DB
			new_pupper = Dog.create(attr_hash)
		else
			#return new pupper object
			new_pupper = Dog.new_from_db(dog)
		end

		new_pupper 
	end

	def self.new_from_db(dog_arr)
		dog_hash = {}
		dog_hash[:id] = dog_arr[0]
		dog_hash[:name] = dog_arr[1]
		dog_hash[:breed] = dog_arr[2]
		Dog.new(dog_hash)
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM dogs WHERE name = ?
		SQL
		
		pupper = DB[:conn].execute(sql, name).flatten
		Dog.new_from_db(pupper)
	end

 	def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end