class Dog
  attr_accessor :id, :name, :breed

  def initialize(attribute_hash)
    @id = attribute_hash[:id] || nil
    @name = attribute_hash[:name]
    @breed = attribute_hash[:breed]
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(attribute_hash)
    new_dog = self.new(attribute_hash)
    new_dog.save
    new_dog
  end

  def save
    !!self.id ? update : insert
    self
  end

  def self.new_from_db(row)
    attr_hash = {name: row[1], breed: row[2]}
    new_dog = self.new(attr_hash)
    # binding.pry
    new_dog.id = row[0]
    new_dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    dog_data = DB[:conn].execute(sql, id).flatten
    self.new({id: dog_data[0], name: dog_data[1], breed: dog_data[2]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    dog_data = DB[:conn].execute(sql, name).flatten
    self.new({id: dog_data[0], name: dog_data[1], breed: dog_data[2]})
  end

  def self.find_or_create_by(attribute_hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attribute_hash[:name], attribute_hash[:breed])
    if !dog.empty?
      dog_id = dog.flatten[0]
      self.find_by_id(dog_id)
    else
      self.create(attribute_hash)
    end
  end
end
