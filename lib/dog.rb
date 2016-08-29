class Dog
  attr_accessor :name, :breed
  attr_reader :id


  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    dog = Dog.new({name: name, breed: breed})
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      SQL
    dogData = DB[:conn].execute(sql, id)[0]
    Dog.new({id: dogData[0], name: dogData[1], breed: dogData[2]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      SQL
    dogData = DB[:conn].execute(sql, name)[0]
    Dog.new({id: dogData[0], name: dogData[1], breed: dogData[2]})
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
      SQL
    dogData = DB[:conn].execute(sql, name, breed)
    if !dogData.empty?
      Dog.new_from_db(dogData[0])
    else
      Dog.create({name: name, breed: breed})
    end
  end

  def self.new_from_db(row)
    Dog.new({id: row[0], name: row[1], breed: row[2]})
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end





end