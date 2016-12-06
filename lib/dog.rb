require 'pry'
class Dog
  
  attr_accessor :name, :breed
  attr_reader :id

	def initialize(id: nil, name:, breed:)
		@name = name
		@breed = breed
		@id = id
	end
  
  def self.create_table
  	sql = <<-SQL
  	  CREATE TABLE IF NOT EXISTS dogs(
  	   id PRIMARY KEY,
  	   name TEXT,
  	   breed TEXT
  	  );
  	 SQL

  	DB[:conn].execute(sql)
  end

  def self.drop_table
  	sql = <<-SQL
  	  DROP TABLE IF EXISTS dogs
  	SQL

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

  def self.create(name:, breed:)
    dog = Dog.new(name:name, breed:breed)
    dog.save
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    Dog.new_from_db(row) 	
  end

  
  def self.find_or_create_by(name:, breed:)
    record_from_db = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

    if !record_from_db.empty?
      data = record_from_db[0]
    	dog = Dog.new(id:data[0], name:data[1], breed:data[2])
    else
    	dog = Dog.create(name:name, breed:breed)
    end
    dog 	
  end
  
  def self.new_from_db(row)
  	Dog.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
  	row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
  	Dog.new_from_db(row)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)	
  end

end