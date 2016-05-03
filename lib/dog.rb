class Dog
  attr_accessor :id, :name, :breed
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  def self.create_table
    table = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      );
SQL
    DB[:conn].execute(table)
  end
  def self.drop_table
    drop = "DROP TABLE dogs"
    DB[:conn].execute(drop)
  end
  def save
    if self.id
      self.update
    else
    save = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(save, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  def self.find_by_id(id)
    find = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
SQL
    new_dog = DB[:conn].execute(find, id)[0]
    Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
  end
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end
  def self.find_by_name(name)
    find = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
SQL
    DB[:conn].execute(find, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end