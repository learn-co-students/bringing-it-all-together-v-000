class Dog
  attr_accessor :name, :breed, :id
  SELECT_ALL = <<-SQL
    SELECT * FROM dogs
  SQL

  def initialize(id:nil,name:,breed:)
     @name = name
     @breed = breed
     @id = id
  end

  def self.exec(query)
    DB[:conn].execute(query)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    exec(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    exec(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(db)
    dog = Dog.new(db)
    dog.save
  end

  def self.hashify(db)
    {name: db[1], breed: db[2], id: db[0]}
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    Dog.new(hashify(DB[:conn].execute(sql, id)[0]))
  end

  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(hashify(dog_data))
    else
      dog = Dog.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(db)
    Dog.new(hashify(db))
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    Dog.new(hashify(DB[:conn].execute(sql, name)[0]))
  end

end
