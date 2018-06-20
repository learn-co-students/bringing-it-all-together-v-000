class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    if !DB[:conn].execute(sql, name, breed).empty?
      self.new_from_db(DB[:conn].execute(sql, name, breed)[0])
    else
      self.create({name: name, breed: breed})
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.new_from_db(array)
    self.new({id: array[0], name: array[1], breed: array[2]})
  end

  def self.find_by_id(int)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, int)[0])
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
end
