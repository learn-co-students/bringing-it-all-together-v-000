class Dog

attr_accessor :name, :breed
attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self. create_table
    sql =  <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
            SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
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
    #binding.pry
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL

    dog_array = DB[:conn].execute(sql,id).flatten
    dog = Dog.new(id:dog_array[0],name:dog_array[1],breed:dog_array[2])
    #binding.pry
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    dog_array = DB[:conn].execute(sql,name,breed).flatten
    if !dog_array.empty?
      dog = Dog.new(id:dog_array[0],name:dog_array[1],breed:dog_array[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    #binding.pry
  end

  def self.new_from_db(row)
    dog = Dog.new(id:row[0],name:row[1],breed:row[2])
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL

    dog_array = DB[:conn].execute(sql,name).flatten
    dog = Dog.new(id:dog_array[0],name:dog_array[1],breed:dog_array[2])
    dog

  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



end
