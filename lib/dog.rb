class Dog

  attr_accessor :name, :breed, :id 

  def initialize(name: nil, breed: nil, id: nil) 
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
      DROP TABLE IF EXISTS dogs 
    SQL

    DB[:conn].execute(sql)
  end

  def save 
    if self.id 
      self.update 
    else 
      sql = <<-SQL 
        INSERT INTO dogs(name, breed)
        VALUES(?,?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
   end
   self 
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save 
    dog
  end

  def self.find_by_id(id_number)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id_number)[0]
    # 'result' gives you this [1, "Kevin", "shepard"]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def self.find_or_create_by(hash)
    name = hash[:name]
    breed = hash[:breed]
    # hash ex = {:name=>"teddy", :breed=>"cockapoo"}
    # # we need to find a sql item from the table
    # # that is the dog 
    # query the database for the dog object 
    # if not existing, we make a new one 
    # either way, you gotta make the object...the db doesnt return objects, just a row of data


    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    # if above exists, we would get an array with the array of the table row - we then create
    # an object out of it but we need logic incase it does exist
    
    if !dog.empty? # if the dog db connection is not empty and matches exactly we just return it
      dog_data = dog[0]
      new_dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else 
      new_dog = self.create(hash)
    end
      new_dog
  end
   

  def self.new_from_db(row)
    # row test data is [1, "Pat", "poodle"]
    dog = self.new(id: row[0], name: row[1], breed: row[2])
  end
 
  def self.find_by_name(name)
     sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name)[0]
    hash = { id: result[0], name: result[1], breed: result[2] }
    Dog.new(hash)

  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ? 
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 

end