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

  # def self.find_or_create_by(attr_hash)
  #   sql = "SELECT * FROM dogs WHERE id = ?"
  #   result = DB[:conn].execute(sql, attr_hash[:id])
  #   binding.pry
  #   if result == nil
  #     self.create(attr_hash)
  #   else
  #     "fishsticks"
  #   end
  #   # if result == nil
  #   # Dog.new
  #   # end
  #
  # end

  # def self.find_or_create_by(attr_hash)
  #   # what if theres a dog that doesn't have an id, but does have a name and breed and is already in the database with an id in there
  #   if DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", attr_hash[:id]).size == 0  # if 0 this indicates the db returned no records, which means we will need to create a dog
  #     dog = Dog.create(attr_hash)
  #     dog
  #   else
  #     # attr_hash[0] = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr_hash[:name], attr_hash[:breed])
  #     # dog = Dog.create(attr_hash)
  #   end
  # end
  # if DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", attr_hash[:id]).size == 0  # if 0 this indicates the db returned no records, which means we will need to create a dog
# dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr_hash[:name], attr_hash[:breed])

def self.find_or_create_by(attr_hash)
  # what if theres a dog that doesn't have an id, but does have a name and breed and is already in the database with an id in there
  dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr_hash[:name], attr_hash[:breed])
  if dog_row[0].size == 0
    new_dog = Dog.create(attr_hash)
  end
end

end
