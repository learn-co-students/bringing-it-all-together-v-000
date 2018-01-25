require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(id=nil, name: name, breed: breed)
    @name=name
    @breed=breed
    @id=id
  end

  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT);
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql="DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql="INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_dog=self.new(row[0], name:row[1], breed:row[2])
    new_dog
  end

  def self.find_by_name(name)
    sql="SELECT * FROM dogs WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
  end

  def self.find_or_create_by(name:, breed:)
    dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed =?", name, breed)
    if !dog_array.empty?
      dog = Dog.new(dog_array[0][0], name:dog_array[0][1], breed:dog_array[0][2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def update
    sql="UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
