class Dog
  attr_accessor :name, :breed
  attr_reader :id


  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end


  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end


  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
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
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end


  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
  end


  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end


  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).first
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end


  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id).first
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end


  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name=? AND breed=?
        SQL

    row = DB[:conn].execute(sql, name, breed).first
    if row == nil
      dog = self.create({name: name, breed: breed})
    else
      dog = self.new(name: row[1], breed: row[2], id: row[0])
    end
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
