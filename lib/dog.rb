class Dog
	
	attr_accessor :name, :breed
	attr_reader :id
	
	def initialize(name:, breed:, id:nil)
		@name = name
		@breed = breed
		@id = id
	end
	
	def self.create_table
		sql=<<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT)
			SQL
		DB[:conn].execute(sql)
	end
	
	def self.drop_table
		sql=<<-SQL
			DROP TABLE dogs
		SQL
		DB[:conn].execute(sql)
	end
	
	def self.new_from_db(row)
		dog = Dog.new(name: row[1], breed: row[2], id: row[0])
		dog
	end
	
	def self.create(name:,breed:,id:nil)
		dog = Dog.new(name: name, breed: breed, id: id)
		dog.save
		dog
	end
	
	def self.find_or_create_by(name:, breed:)
		sql=<<-SQL
			SELECT * FROM dogs WHERE name=? AND breed=?
		SQL
		dog = DB[:conn].execute(sql, name, breed)
		if dog[0].nil?
			dog = Dog.create(name: name, breed: breed)
			dog
		else
			dog2 = Dog.new(name: name, breed: breed,id: dog[0][0])
			dog2
		end
	end
	
	def self.find_by_name(name)
		sql=<<-SQL
			SELECT * FROM dogs WHERE name=?
			SQL
		all = DB[:conn].execute(sql, name)
		all.map { |x| Dog.new_from_db(x) }.first
	end
	
	def self.find_by_id(id)
		sql=<<-SQL
			SELECT * FROM dogs WHERE id=?
		SQL
		dog = DB[:conn].execute(sql, id)[0]
		Dog.new_from_db(dog)
	end
	def update
		sql=<<-SQL
			UPDATE dogs SET name=?, breed=? WHERE id=?
		SQL
		DB[:conn].execute(sql,self.name,self.breed,self.id)
	end
	
	
	def save
		if !self.id.nil?
			self.update
		else
			sql=<<-SQL
				INSERT INTO dogs (name, breed) VALUES (?,?)
			SQL
			DB[:conn].execute(sql,self.name,self.breed)
			@id= DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		end
	end
	
end