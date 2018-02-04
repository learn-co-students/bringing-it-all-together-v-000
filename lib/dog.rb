class Dog

	attr_accessor :name, :breed, :id

	def initialize(hash) #could also initialize w/ (id:nil, name:, breed:), would need to remove hash statement below and sub in @name & @breed
		hash.each {|key, value| self.send(("#{key}="), value)}
		@id = id
		#@name = name
		#@breed = breed
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
		sql = "DROP TABLE IF EXISTS dogs"

		DB[:conn].execute(sql)
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL
				INSERT INTO dogs (name, breed)
				VALUES(?, ?)
			SQL

			DB[:conn].execute(sql, self.name, self.breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		end
		self
	end

	def update
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

	def self.new_from_db(row)
		id = row[0]
		name = row[1]
		breed = row[2]
		new_dog = Dog.new(id: id, name: name, breed: breed)
		new_dog
	end

	def self.create(name:, breed:)
		new_dog = Dog.new(name: name, breed: breed)
		new_dog.save
		new_dog
	end

  def self.find_by_name(name)
  	sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE name = ?
			LIMIT 1
  	SQL

  	DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
  end

  def self.find_by_id(id)
  	sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE id = ?
			LIMIT 1
  	SQL

  	DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
  end

  def self.find_or_create_by(name:, breed:)
  	dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  	if !dog.empty?
  		dog_deets = dog[0]
  		dog = Dog.new(id: dog_deets[0], name: dog_deets[1], breed: dog_deets[2])
  	else
  		dog = self.create(name: name, breed: breed)
  	end		
  end

end