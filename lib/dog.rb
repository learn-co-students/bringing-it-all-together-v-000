class Dog

  attr_accessor :id, :name, :breed

  def initialize (id = nil, name, breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed, TEXT
        );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (
        ?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    new_id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self.id = new_id
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name, breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id (find_id)
    query = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?;
      SQL
    found = DB[:conn].execute(query, find_id)[0]
    new_dog = Dog.new(found[0], found[1], found[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    if dog.size > 0
      dog_info = dog[0]
      dog = Dog.new_from_db(dog_info)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    query = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?;
      SQL
    found = DB[:conn].execute(query, name)[0]
    self.new_from_db(found)
  end

  def update
    query = <<-SQL
      UPDATE dogs 
      SET name = ?, breed = ?
      WHERE id = ?;
      SQL
    DB[:conn].execute(query, self.name, self.breed, self.id)
  end

end









