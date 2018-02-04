class Dog
  attr_accessor :name, :breed, :id
    
  def initialize (name: null, breed: null, id: nil)
    @name = name
    @breed = breed
    @id = id
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
  
  def self.new_from_db(db_row)
    Dog.new(id: db_row[0], name: db_row[1], breed: db_row[2])
  end
  
  def self.find_by_id(id_to_find)
      sql = "SELECT * FROM dogs WHERE id = ?"
      Dog.new_from_db(DB[:conn].execute(sql, id_to_find)[0])
  end
  
  def self.find_or_create_by(name:, breed:)
      sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
      dog_find = DB[:conn].execute(sql, name, breed)[0]
      new_dog = nil
      if dog_find
        new_dog = Dog.new_from_db(dog_find)
      else
        new_dog = Dog.create(name: name, breed: breed)
      end
      new_dog
  end
  
  def self.find_by_name(name_to_find)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    Dog.new_from_db(DB[:conn].execute(sql, name_to_find)[0])
  end
  
  def self.create(name:, breed:)
      new_dog = Dog.new(name: name, breed: breed)
      new_dog.save
      new_dog
  end
  
  def save
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      return self
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,
      breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end
