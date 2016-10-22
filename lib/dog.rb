class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id:nil)
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
    DB[:conn].execute("DROP TABLE dogs")
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

  def self.create(dog_hash)
    dog = self.new(dog_hash)
    dog.save
    dog
  end

  def self.new_from_db(row)
    self.new(name:row[1], breed:row[2], id:row[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog = DB[:conn].execute(sql, id)[0]
    self.new_from_db(dog)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    dog = DB[:conn].execute(sql, name)[0]
    self.new_from_db(dog)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(name:, breed:)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog_data.empty?
      dog = self.new_from_db(dog_data[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
end
