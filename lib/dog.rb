require 'pry'
class Dog

	attr_accessor :name, :breed, :id

	def initialize(hash)
		hash.each { |attr, value| self.send("#{attr}=", value) }
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
  	if self.id
    	self.update
  	else
    	sql = <<-SQL
      	INSERT INTO dogs (name, breed) 
      	VALUES (?, ?)
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

  def self.create(hash)
  	new_dog = self.new(hash)
  	new_dog.save
  end

  def self.find_by_id(id)
  	sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    hash = {}
    hash[:id] = result[0]
    hash[:name] = result[1]
    hash[:breed] = result[2]
    Dog.new(hash)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      hash = {}
	    hash[:id] = dog_data[0]
	    hash[:name] = dog_data[1]
	    hash[:breed] = dog_data[2]
      dog = Dog.new(hash)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
  	hash = {}
    hash[:id] = row[0]
    hash[:name] = row[1]
    hash[:breed] = row[2]
    dog = Dog.new(hash)
  end

  def self.find_by_name(name)
  	sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    hash = {}
    hash[:id] = result[0]
    hash[:name] = result[1]
    hash[:breed] = result[2]
    Dog.new(hash)
  end
end