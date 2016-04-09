class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end
  
  def self.new_from_db(db_values)
    new_dog = self.new({id: db_values[0], name: db_values[1], breed: db_values[2]})
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY, 
    name text, 
    breed text);
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
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed) 

      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    self.new_from_db(result)
  end

  def self.find_or_create_by(attributes)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    result = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
    if !result.empty?
      data = result[0]
      dog = self.new_from_db(data)
    else
      dog = self.create(attributes)
    end
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed =?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

