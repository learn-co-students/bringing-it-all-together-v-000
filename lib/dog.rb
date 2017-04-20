class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
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
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    dog_hash = {id: row[0], name: row[1], breed: row[2] }
    new_dog = self.new(dog_hash)
    new_dog
  end


  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten

    self.new_from_db(row)
  end
    
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten

    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_row = dog[0]
      dog = self.new_from_db(dog_row)
    else
      song = self.create(name: name, breed: breed)
    end
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


