class Dog
	attr_accessor :name, :breed
	attr_reader :id

	def self.create_table()
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.create(input_hash)
    new_dog = self.new(input_hash)
    new_dog.save
    new_dog
  end

	def initialize(input_hash)
		self.name = input_hash[:name]
		self.breed = input_hash[:breed]
		@id = input_hash[:id]
	end

 def self.new_from_db(row)
    # create a new Dog object given a row from the database
		params = {id: row[0], name: row[1], breed: row[2]}

		new_dog = self.new(params)
		new_dog
  end

  def self.find_by_name_and_breed(name, breed)
    # find the dog in the database given a name and a breed
    # return a new instance of the dog class
		
		sql = <<-SQL
			SELECT * 
			FROM dogs 
			WHERE name = ? AND breed = ?
			LIMIT 1
		SQL

		rtn = DB[:conn].execute(sql, name, breed)

		rtn.map do |row|
			self.new_from_db(row)
		end.first
  end

def self.find_by_id(id)
    # find the dog in the database given an id
    # return a new instance of the Dog class

    sql = <<-SQL
      SELECT * 
      FROM dogs 
      WHERE id = ?
      LIMIT 1
    SQL

    rtn = DB[:conn].execute(sql, id)

    rtn.map do |row|
      self.new_from_db(row)
    end.first
  end
	
	def self.find_by_name(name)
    # find the dog in the database given a name
    # return a new instance of the Dog class

    sql = <<-SQL
      SELECT * 
      FROM dogs 
      WHERE name = ?
      LIMIT 1
    SQL

    rtn = DB[:conn].execute(sql, name)

    rtn.map do |row|
      self.new_from_db(row)
    end.first
  end

	def self.find_or_create_by(input_hash)
		the_dog = self.find_by_name_and_breed(input_hash[:name], input_hash[:breed])

		return the_dog if !!the_dog
		
		the_dog = self.new(input_hash)	
		the_dog.save
		the_dog
	end

	def save
		if !!id
			self.update
			return self
		end

    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end
  
	def update
		sql = <<-SQL
			UPDATE dogs 
			SET name = ?, breed = ?
			WHERE id = ?
		SQL

		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end
end
