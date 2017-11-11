class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    @id = nil
    attributes.each {|key, value| self.send(("#{key}="), value)}
    self
  end

  def self.create_table
    sql =  <<-SQL
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
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    hash = {}
    hash[:id] = result[0]
    hash[:name] = result[1]
    hash[:breed] = result[2]
    Dog.new(hash)
  end

  def self.find_or_create_by(attributes)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
    if !dog.empty?
      dog = Dog.find_by_name(attributes[:name])
    else
      dog = self.create(attributes)
    end
    dog
  end

  def self.new_from_db(row)
    hash = {}
    hash[:id] = row[0]
    hash[:name] = row[1]
    hash[:breed] = row[2]
    Dog.new(hash)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    hash = {}
    hash[:id] = result[0]
    hash[:name] = result[1]
    hash[:breed] = result[2]
    Dog.new(hash)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
