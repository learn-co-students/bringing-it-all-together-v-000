class Dog
  attr_accessor :id, :name, :breed
  def initialize(attributes)
    attributes.each {|k,v| self.send(("#{k}="),v)}
  end

  def self.create_table
    drop_table
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

  def self.new_from_db(row)
    attributes = {id: row[0], name: row[1], breed: row[2]}
    dog = Dog.new(attributes)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.find_by_id(num)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(sql, num)[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      data = dog[0]
      dog = Dog.new({id: data[0], name: data[1], breed: data[2]})
    else
      dog = self.create({name: name, breed: breed})
    end
    dog
  end

end
