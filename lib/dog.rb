require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes) #take in a dog has {:name=>"Fido", :breed=>"lab"}
    attributes.each {|key, value| self.send(("#{key}="),value)} #create array from key and value pairs for the args passed in
    self.id ||= nil
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
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id) #just like the student lab self.find_by_name method...
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new_from_db(dog_data) #[0], dog_data[1], dog_data[2])
    else
      dog = self.create({name: name, breed: breed})
    end
    dog
  end

  def self.new_from_db(row)
    hash = {
      id: row[0],
      name: row[1],
      breed: row[2]
    }
      self.new(hash)
    end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    data = DB[:conn].execute(sql, name)[0]
    dog = self.new_from_db(data)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
