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


def self.find_or_create_by(attr_hash)
  if attr_hash[:id] == nil #ie if theres no id value in the attr_hash
    # looks for a dog that doesn't have an id in its hash, but does have a name and breed and is already in the database with an id in there
    dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr_hash[:name], attr_hash[:breed]) #check for a breed and name that match and save the returned row
    if dog_row[0].size == 0
      # no dogs in here so create a dog from the hash then save it to the db
      dog = Dog.create(attr_hash)
    elsif dog_row[0].size > 0 #if its greater than zero then create a dog object
      dog = Dog.new(name: dog_row[0][1], breed:dog_row[0][2], id: dog_row[0][0])
      dog.save
  else
    self.find_by_id(attr_hash[:id])
    end
  end
end

end
