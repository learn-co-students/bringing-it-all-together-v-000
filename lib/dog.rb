require 'pry'
class Dog

attr_accessor :name, :breed
attr_reader :id

  def initialize(args)
    @id = args[:id]
    @name = args[:name]
    @breed = args[:breed]
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
    sql = "DROP TABLE dogs"

    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(args)
    dog = Dog.new(args)
    dog.save
  end

  def self.find_by_id(i)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    LIMIT 1
    SQL

    dog = DB[:conn].execute(sql, i)[0]

    args = {:id => i, :name => dog[1], :breed => dog[2]}
    d = Dog.new(args)
  end

  def self.new_from_db(row)
    args = {:id => row[0], :name => row[1], :breed => row[2]}
    new_dog = Dog.new(args)
  end

  def self.find_or_create_by(args)
    name = args[:name]
    breed = args[:breed]

    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

    if !dog.empty?
      dog_data = dog[0]
      new_args = {:id => dog_data[0], :name => dog_data[1], :breed => dog_data[2]}
      dog = Dog.new(new_args)
      dog

    else
      dog = self.create(args)
      dog
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL

    dog = DB[:conn].execute(sql, name)[0]

    args = {:id => dog[0][0], :name => dog[1], :breed => dog[2]}
    d = Dog.new(args)
  end

end
