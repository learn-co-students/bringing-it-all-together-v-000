require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(id=nil,name: nil,breed: nil)
    @id = id
    @name = name     
    @breed =  breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY,name TEXT,breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name,breed) VALUES (?,?);"
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
  end

  def self.create(attr_hash)
    dog = Dog.new
    attr_hash.each {|key,value| dog.send(("#{key}="),value)}
    dog.save
    dog
  end

  def self.find_by_id(id)
    dog = Dog.new
    sql = "SELECT * FROM dogs WHERE id=(?);"
    DB[:conn].execute(sql,id).map do |row|
      dog.id = row[0]
      dog.name = row[1]
      dog.breed = row[2]
    end
    dog
  end

  def self.find_or_create_by(name:,breed:)
    sql = "SELECT * FROM dogs WHERE name=(?) AND breed=(?);"
    dog = DB[:conn].execute(sql,name,breed)
    if !dog.empty?
      dog_data=dog[0]
      dog = Dog.new(dog_data[0],name: dog_data[1],breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name=(?) LIMIT 1;"
    row = DB[:conn].execute(sql,name).first
    Dog.new(row[0],name: row[1],breed: row[2])
  end

  def update
    sql = "UPDATE dogs SET name=(?),breed=(?) WHERE id=(?);"
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end
end