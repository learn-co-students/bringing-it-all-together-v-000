class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
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
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    Dog.new(hash).save
  end

  def self.find_by_id(id)
    dog_info = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    Dog.new(name: dog_info[1], breed: dog_info[2], id: dog_info[0])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten

    if !dog.empty?
      self.new(id: dog[0], name: dog[1], breed: dog[2])
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    self.new(name: dog[1], breed: dog[2], id: dog[0])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end
