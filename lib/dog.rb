class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
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
    if self.id
      self.update
    else
      self.insert
      return self
    end
  end

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    return dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
    if !dog.empty?
      dog_info = dog[0]
      dog = self.new_from_db(dog_info)
    else
      dog = self.create(name:name, breed:breed)
    end
    return dog
  end

  def self.new_from_db(row)
    attributes = {}
    attributes[:id] = row[0]
    attributes[:name] = row[1]
    attributes[:breed] = row[2]
    dog = Dog.new(attributes)
    return dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
end
