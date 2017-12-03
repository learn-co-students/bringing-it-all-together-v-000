class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
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

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    puts result
    Dog.new({id: result[0], name: result[1], breed: result[2]})
  end

  def self.find_or_create_by(attributes)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new({id: dog_data[0], name: dog_data[1], breed: dog_data[2]})
    else
      dog = self.create(attributes)
    end
    dog
  end

  def self.new_from_db(row)
    self.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_by_name(name)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new({id: dog_data[0], name: dog_data[1], breed: dog_data[2]})
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
