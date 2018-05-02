class Dog
  attr_reader :id, :name, :breed
  attr_writer :name, :breed

  def initialize (id: nil, name:, breed:)
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
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.create (name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
  end

  def self.find_by_id (id)
    sql = "SELECT * FROM dogs WHERE id=?"
    row = DB[:conn].execute(sql,id).first
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def save
    if !id
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      update
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by (name:, breed:)
    sql="SELECT * FROM dogs WHERE name=? AND breed=?"
    row = DB[:conn].execute(sql, name, breed)
    if row.empty?
      dog = self.create(name: name, breed: breed)
    else
      dog = self.new_from_db(row.first)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql="SELECT * FROM dogs WHERE name=?"
    row = DB[:conn].execute(sql, name).first
    self.new_from_db(row)
  end

end
