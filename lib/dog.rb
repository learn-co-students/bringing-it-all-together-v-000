require 'pry'
class Dog
  attr_accessor :id, :name, :breed
  def initialize(option)
    option.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.create_table
    sql =  <<-SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
  end

  def save
    if self.id
      self.update
    else
      sql =  <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.find_by_name(name)
    sql =  <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL
    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql =  <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(option)
    dog = self.new(option)
    dog.save
  end

  def self.find_by_id(id)
    sql =  <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    new_from_db(row)
  end

  def self.find_or_create_by(option)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", option[:name], option[:breed])
    if !dog.empty?
      dog_data = dog[0]
      hash = {id:dog_data[0], name:dog_data[1], breed:dog_data[2]}
      dog = self.new(hash)
    else
      dog = self.create(option)
    end
  end

end
