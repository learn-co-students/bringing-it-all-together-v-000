class Dog

  require 'pry'
  attr_accessor :name, :breed, :id

  def initialize(data, id = nil)
    @id = id
    data.each{|key,value| self.send("#{key}=",value)}
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
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(row)
    new_dog = Dog.new(row)
    new_dog.save
    new_dog
  end

  def self.find_by_id(num)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, num)[0]
    Dog.new(name:result[1], breed:result[2], id:result[0])
  end

  def self.new_from_db(row)
    dog = Dog.new(name:row[1], breed:row[2], id:row[0])
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    result = DB[:conn].execute(sql,name)[0]
    Dog.new(name:result[1], breed:result[2], id:result[0])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def self.find_or_create_by(row)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", row[:name], row[:breed])
     if !dog.empty?
       dog_data = dog[0]
       dog = Dog.new(name:dog_data[1], breed:dog_data[2], id:dog_data[0])
     else
       dog = self.create(name:row[1], breed:row[2], id:row[0])
     end
     dog
  end

end
