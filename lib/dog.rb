class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil , name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql_query = <<-SQL
  CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    grade TEXT);
    SQL
    DB[:conn].execute(sql_query)
  end

  def self.drop_table
    sql_query = <<-SQL
     DROP TABLE dogs
                 SQL
   DB[:conn].execute(sql_query)
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
    @id = DB[:conn].execute("SELECT * FROM dogs ORDER BY id DESC LIMIT 1").flatten[0]
    end
    self
  end

  def self.new_from_db(row)
    Dog.new(id: row[0],name: row[1],breed: row[2])
  end


  def self.create(name: , breed:)
    Dog.new(name: name, breed: breed).save
  end


  def self.find_by_name(name)
    row= DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name).flatten
    new_from_db(row)
  end


  def self.find_by_id(id)
    row= DB[:conn].execute("SELECT * FROM dogs WHERE id = ? LIMIT 1", id).flatten
    new_from_db(row)
  end

  def self.find_or_create_by(name: , breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
   if !dog.empty?
     dog_data = dog[0]
     dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
   else
     dog = self.create(name: name, breed: breed)
   end
   dog
 end


  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id= ?", @name, @breed, @id)
  end




end
