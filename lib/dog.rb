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
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
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

  def self.create(attr)
    new_dog = self.new(attr)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    dog = DB[:conn].execute(sql, id)[0]

    self.new(id: dog[0], name: dog[1], breed: dog[2])
  end

  def self.find_or_create_by(attr)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr[:name], attr[:breed])

    if !dog.empty?
      dog_data = dog[0]
      self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      self.create(attr)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    dog = DB[:conn].execute(sql, name)[0]

    self.new_from_db(dog)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE ID = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
