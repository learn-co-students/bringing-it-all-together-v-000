class Dog 
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table()
    sql =  <<-SQL 
    CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT, 
    breed TEXT
    );
    SQL
    DB[:conn].execute(sql) 
  end
  
  def self.drop_table
   sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(row)
      Dog.new(id:row[0], name:row[1], breed:row[2])
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(id:result[0], name:result[1], breed:result[2])
  end
  
  def self.create(name)
    dog = Dog.new(name)
    dog.save
    dog
  end
  
  def self.find_or_create_by(name: , breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
   
    if !dog.empty? 
      data = dog[0]
      dog = Dog.new(id: data[0], name: data[1], breed: data[2])
       #binding.pry
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id:result[0], name:result[1], breed:result[2])
  end
  
  def update
    sql = "UPDATE dogs SET id = ?, name = ? WHERE breed = ?"
    DB[:conn].execute(sql, self.id, self.name, self.breed)
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
    self
  end
end
  
end