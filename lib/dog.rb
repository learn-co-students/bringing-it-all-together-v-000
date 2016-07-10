class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
  end
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
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
  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      Dog.new_from_db(dog[0])
    else
      Dog.create(hash)
    end
  end
  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end
  def self.new_from_db(row)
    hash = {:id => row[0], :name => row[1], :breed => row[2]}
    Dog.new(hash)
  end
  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id).flatten
    Dog.new_from_db(row)
  end
  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", name).flatten
    Dog.new_from_db(row)
  end
  def self.find_by_breed(breed)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE breed = ?;", breed).flatten
    Dog.new_from_db(row)
  end
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
