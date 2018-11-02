require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id
   @name = name
   @breed = breed
 end
 def self.create_table
   sql= <<-SQL
   CREATE TABLE IF NOT EXISTS dogs (
     id INTEGER PRIMARY KEY,
     name TEXT,
     breed TEXT
     )
    SQL
    DB[:conn].execute(sql)
 end
  def self.drop_table
    sql= "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql= <<-SQL
      INSERT INTO dogs(name,breed)
      VALUES(?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:,breed:)
    dog = Dog.new(name: name,breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    arr = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",id).flatten
    Dog.new(id: arr[0],name: arr[1], breed: arr[2])
  end

  def self.find_or_create_by(name:,breed:)
     dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten

     if !dog_data.empty?
          dog = Dog.new(id: dog_data[0], name:  dog_data[1], breed:  dog_data[2])

     else
         dog = Dog.create(name: name,breed: breed)
     end
      dog
  end

  def self.new_from_db(row)
     new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
     new_dog
  end

  def self.find_by_name(name)
    arr = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name).flatten
    self.new_from_db(arr) #envio el dato al metodo para que me cree un instancia
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end
