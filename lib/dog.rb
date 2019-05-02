class Dog

  attr_accessor :name, :breed, :id

  def initialize (id:nil,breed:,name:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
        INSERT INTO dogs (name,breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      sql = "SELECT last_insert_rowid() FROM dogs"
      DB[:conn].execute(sql).flatten.first
      self.id = DB[:conn].execute(sql).flatten.first
    end
      self
  end

  def self.create(name:,breed:)
    new_dog = self.new(name:name, breed:breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    dog = self.new(id:row[0],name:row[1],breed:row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql,id)
    new_dog = self.new_from_db(row.flatten)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql,name)
    self.new_from_db(row.flatten)

  end

  def self.find_or_create_by(name:,breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql,name,breed)
    if !row.empty? #if there is row for that dog in the db
      self.find_by_id(row[0][0])
    else
      self.create(name:name, breed:breed)
    end
  end

  def update()
    sql = <<-SQL
      UPDATE dogs set
      name = ?,
      breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end


end
