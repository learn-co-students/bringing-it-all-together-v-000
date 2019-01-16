require 'pry'
class Dog
attr_accessor :name, :breed
attr_reader :id


  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
  end

  def self.create_table
    sql =<<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =<<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql =<<-SQL
      INSERT INTO dogs (name,breed)
      VALUES (?,?)
      SQL

      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
      self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql,id)[0]
    dog = Dog.new({:id=>result[0], :name=>result[1], :breed=>result[2]})
    dog
  end

  def self.find_or_create_by(hash)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name],hash[:breed])
    if !result.empty?
      dog = Dog.new({:id=> result[0][0], :name=>result[0][1], :breed=>result[0][2]})
    else
      dog = self.create(hash)
    end
    dog
  end

  def self.new_from_db(hash)
    dog = Dog.new({:id=> hash[0], :name=>hash[1], :breed=>hash[2]})
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql,name)
    dog = Dog.new({:id=> result[0][0], :name=>result[0][1], :breed=>result[0][2]})
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
