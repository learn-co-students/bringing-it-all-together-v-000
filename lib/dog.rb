class Dog
  attr_accessor :name, :breed, :id


  def initialize(attrs)
    attrs.each { |attr, value| self.send(("#{attr}="), value)}
  end

  def self.create_table
    sql= <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
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
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
      SQL

      result = DB[:conn].execute(sql, id).flatten

      Dog.new_from_db(result)
  end

  def self.find_or_create_by(attr_hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL

    dog = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed]).flatten

    if dog.empty?
      new_dog = Dog.create(attr_hash)
    else
      new_dog = Dog.new_from_db(dog)
    end
    new_dog
  end


  def self.new_from_db(row)
    hash = {:id => row[0],
      :name => row[1],
      :breed => row[2]
    }

    Dog.new(hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name).flatten

    Dog.new_from_db(result)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
