require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs
    ( id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL

      row = DB[:conn].execute(sql, self.name, self.breed)[0]
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self #have to return the newly stored instance to reflect creation
  end

  def self.create(name: name, breed: breed)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id=(?)
    SQL

    row = DB[:conn].execute(sql, id)[0]
    dog_instance = self.new(id: row[0], name: row[1], breed: row[2])
   end

  def self.find_or_create_by(name: name, breed: breed)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name=(?) AND breed=(?)
    SQL

    query = DB[:conn].execute(sql, name, breed)

    if query.empty?
      query = self.create(name: name, breed: breed)
    else
      dog_instance = query[0]
      query = self.new(id: dog_instance[0], name: dog_instance[1], breed: dog_instance[2])
    end
      query
  end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(dog)
    sql = <<-SQL
          SELECT * FROM dogs
          WHERE name=(?)
          SQL

    row = DB[:conn].execute(sql, dog)[0]
    dog_instance = self.new_from_db(row)
  end

  def update
    binding.pry
    sql = <<-SQL
    UPDATE dogs SET name=(?), breed=(?)
    WHERE id=(?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
