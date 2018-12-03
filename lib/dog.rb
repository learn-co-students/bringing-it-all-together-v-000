class Dog
  attr_accessor :id, :name, :breed

  def initialize (id: nil, name:, breed:)
    self.id = id
    self.name = name
    self.breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE
      IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).collect {|row|
      self.new_from_db(row)
    }.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).collect {|row|
      self.new_from_db(row)
    }.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog_row = DB[:conn].execute(sql, name, breed)
    if !dog_row.empty?
      dog = dog_row.first
      self.new_from_db(dog)
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)

      sql = <<-SQL
        SELECT last_insert_rowid() FROM dogs
      SQL
      self.id = DB[:conn].execute(sql)[0][0]
    end

    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
