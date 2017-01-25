require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
     attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def Dog::create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def Dog::drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)

  end

  def save
    if self.id
      self.update

    else
      sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES(?,?)

      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def Dog::create(create_dog)
    dog = Dog.new(create_dog)
    dog.save
  end

  def Dog::find_by_id(id)

    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?

    SQL
    new_dog = DB[:conn].execute(sql, id)

    dog = Dog.create(name: new_dog[0][1], breed: new_dog[0][2])
    dog.id = id
    dog
  end

  def Dog::find_or_create_by(found)

    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    AND breed = ?

    SQL
    is_found = DB[:conn].execute(sql, found[:name], found[:breed])
    if !is_found.empty?
      find = Dog.new(name: is_found[0][1], breed: is_found[0][2])
      find.id = is_found[0][0]
    else
      find = Dog.create(found)
    end
    find

  end


  def Dog::new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2])
    dog.id = row[0]
    dog
  end

  def Dog::find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?

    SQL
    result = DB[:conn].execute(sql, name)[0]
    dog = Dog.new(name: result[1], breed: result[2])
    dog.id = result[0]
    dog

  end


  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?

    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)


  end
end
