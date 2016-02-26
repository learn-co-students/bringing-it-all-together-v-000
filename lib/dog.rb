class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
    SQL
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES(?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    dog_data = DB[:conn].execute(sql, id).flatten
    dog = self.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    dog
  end

  def self.find_or_create_by(hash)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog_data = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
    if !dog_data.empty?
      dog = self.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else
      dog = self.create(name: hash[:name], breed: hash[:breed])
    end
    dog
  end

  def self.new_from_db(row)
    dog = self.new(name: row[1], breed: row[2], id: row[0])
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, name).flatten)
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