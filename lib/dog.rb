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
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end


  def self.find_by_id(id)
    DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id).map {|row| self.new_from_db(row)}[0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", name).map {|row| self.new_from_db(row)}[0]
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?;", self.name, self.breed, self.id);
  end

  def self.find_or_create_by(name:, breed:)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
    if dog_data.empty?
      dog = self.create(name: name, breed: breed)
    else
      dog = self.new_from_db(dog_data[0])
    end
  end


end
