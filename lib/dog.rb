class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
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
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2])
    dog.id = row[0][0]
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).collect do |row|
      @dog = self.new_from_db(row)
      @dog.id = row[0]
    end
    @dog
  end

  # if one exists with same name but different breed

  # if one exists with same breed but different name

  def self.find_or_create_by(name:, breed:)
    # creates an instance of a dog if it does not already exist
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name, breed)
    if dog.empty?
      @dog_instance = Dog.create(name: name, breed: breed)
    else
      dog_data = dog[0]
      @dog_instance = Dog.new(name: dog_data[1], breed: dog_data[2])
      @dog_instance.id = dog_data[0]
    end
    @dog_instance
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, name).collect do |row|
      @dog = self.new_from_db(row)
      @dog.id = row[0]
    end
    @dog
  end

  def update
    sql = ("UPDATE dogs SET name = ?, breed = ? WHERE id = ?;")
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
