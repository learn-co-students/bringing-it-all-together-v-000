class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name: name , breed: breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.find_by_id(row[0])
  end

  def self.create(hash)
    dog = self.new(name: hash[:name], breed: hash[:breed])
    dog.save
    dog
  end

  def self.find_by_id(id)
    info = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    dog = self.new_from_db(info)
    dog
  end

  def self.find_or_create_by(name: name, breed: breed)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    if row
      dog = self.find_by_id(row[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", @name, @breed, @id)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    #self.drop_table
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
end
