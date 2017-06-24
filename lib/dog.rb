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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid()").flatten.first
      self
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.create(attributes_hash)
    self.new(attributes_hash).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
       SELECT * FROM dogs
       WHERE id = ?
    SQL
    attributes_array = DB[:conn].execute(sql, id).flatten
    Dog.new_from_db(attributes_array)
  end

  def self.find_by_name(name)
    sql = <<-SQL
       SELECT * FROM dogs
       WHERE name = ?
    SQL
    attributes_array = DB[:conn].execute(sql, name).flatten
    Dog.new_from_db(attributes_array)
  end

  def self.find_or_create_by(attributes_hash)
     found_dog = self.find_by_name(attributes_hash[:name])
     if found_dog.name != attributes_hash[:name] || found_dog.breed != attributes_hash[:breed]
       self.create(attributes_hash)
     else
       found_dog
     end
  end
  
end
