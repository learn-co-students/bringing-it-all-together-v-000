class Dog

  attr_accessor :name, :breed, :id

  def initialize(name: , breed: , id: nil)
    @name = name
    @breed = breed
    @id = id
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
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attr_hash)
    # binding.pry
    dog = Dog.new(name: attr_hash[:name], breed: attr_hash[:breed], id: attr_hash[:id])
    dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog_row = DB[:conn].execute(sql, id)
    new_dog = Dog.new(name: dog_row[0][1], breed:dog_row[0][2], id: dog_row[0][0])
  end


def self.find_or_create_by(name:,breed:)
  dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  if dog_row.size == 0
    self.create(name: name, breed: breed)
  else
    self.new(id: dog_row[0][0], name: dog_row[0][1], breed: dog_row[0][2])
  end
end

def self.new_from_db(db_row)
  self.new(name: db_row[1] , breed: db_row[2] , id: db_row[0])
end

def self.find_by_name(name_from_db)
  row_from_db = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name_from_db)
  self.new(name: row_from_db[0][1] , breed: row_from_db[0][2] , id: row_from_db[0][0])
end

def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end

end
