class Dog

attr_accessor :name, :breed
attr_reader :id

  def initialize(id: nil, name: nil, breed: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * from dogs
      WHERE id = ?
    SQL

    dog_data = DB[:conn].execute(sql, id)[0]
    self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end

  def self.find_or_create_by(hash)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !dog.empty?
      dog_id = dog[0][0]
      self.find_by_id(dog_id)
    else
      dog = self.create(hash)
    end
  end

  def self.new_from_db(row)
     attr_hash = {id: row[0], name: row[1], breed: row[2]}
     self.create(attr_hash)
  end

  def self.find_by_name(name)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end

  def update
    binding.pry
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
