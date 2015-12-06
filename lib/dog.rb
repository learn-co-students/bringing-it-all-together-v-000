class Dog 
  attr_accessor :id, :name, :breed

  def initialize(id=nil, name, breed)
    @id, @name, @breed = id, name, breed
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save 
    if self.id 
      self.update
    else
      sql = <<-SQL 
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    end
  end

  def self.create(name:, breed:)
    dog = Dog.new(name, breed)
    dog.save 
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog = DB[:conn].execute(sql, id)[0]
    Dog.new(dog[0], dog[1], dog[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'"
    dog = DB[:conn].execute(sql) 

    dog = if !dog.empty?
      Dog.new(dog[0][0], dog[0][1], dog[0][2])
    else
      self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id, name, breed)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map{ |row| new_from_db(row) }.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end