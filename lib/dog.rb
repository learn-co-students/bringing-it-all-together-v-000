require_relative "../config/environment.rb"

class Dog
  attr_accessor :name, :breed, :id
  def initialize (id: nil,name:, breed:)
    @id = id
    @name=name
    @breed=breed
  end#end the init
#############################
  def self.create_table
  sql = "CREATE TABLE IF NOT EXISTS dogs( id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
  DB[:conn].execute(sql)
  end#end the create table
#############################
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end #end the drop_table
#############################
  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end #end the if
    self
  end #end the save
  ##############
  def update
    sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end #end the update
  ############
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end #end the create method
  ###############
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs where id = ? LIMIT 1"
    DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
    end.first
  end #end the find by id
  ##############################
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end #end the new from databas
  #################################
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    unless dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end #end the unless else
    dog
  end#end the find or create
  ###################################
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs where name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
    end.first
  end #end the find by name
  ###############################
  def update
    sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end #end the update
end #end the Dog class