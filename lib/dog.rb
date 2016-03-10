require_relative "../config/environment.rb"

class Dog
  attr_accessor :id, :name, :breed

  def initialize(hash={:id => nil, :name => name, :breed => breed})
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
  end

  def self.create(name:,breed:)
    x = Dog.new(hash={:name => name, :breed => breed})
    x.save
    x
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(row)
      p = self.new(hash={:id => row[0], :name => row[1], :breed => row[2]})
  end

  def self.all
    sql = <<-SQL
    SELECT * FROM dogs
    SQL

    DB[:conn].execute(sql).collect {|row|
      self.new_from_db(row)
      }
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    LIMIT 1
    SQL
    x = nil
    DB[:conn].execute(sql, id).collect {|row|
      x = self.new_from_db(row)
      }
    x
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL
    x = nil
    DB[:conn].execute(sql, name).collect {|row|
      x = self.new_from_db(row)
      }
    x
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
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

  def self.find_or_create_by(name:, breed:)
    obj = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !obj.empty?
      obj_data = obj[0]
      obj = Dog.new(id: obj_data[0], name: obj_data[1], breed: obj_data[2])
    else
      obj = self.create(name: name, breed: breed)
    end
    obj
  end 



end
