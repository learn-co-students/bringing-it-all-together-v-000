class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each {|k, v| self.send("#{k}=", v)}
  end

  def self.create_table
    sql = <<-SQL
             CREATE TABLE IF NOT EXISTS dogs(
               id INTEGER PRIMARY KEY,
               name TEXT,
               breed TEXT
             );
             SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
            DROP TABLE IF EXISTS dogs;
          SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
          SQL
    row = DB[:conn].execute(sql, id).flatten
    attributes = {id: row[0], name: row[1], breed: row[2]}
    Dog.new(attributes)
  end

  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
    attributes = {id: row[0], name: row[1], breed: row[2]}
    if row.empty?
      dog = self.create({name: name, breed: breed})
    else
      dog = self.new(attributes)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    dog_from_db = Dog.new({id:dog[0], name:dog[1], breed:dog[2]})
    dog_from_db
  end

  def update
    sql = "UPDATE dogs SET id = ?, name = ?, breed = ?;"
    DB[:conn].execute(sql, self.id, self.name, self.breed)
  end
end
