require "pry"
class Dog
  attr_accessor :id, :name, :breed
  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    self.drop_table
    sql =  <<-SQL
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
      @id = DB[:conn].execute("SELECT last_insert_rowid();")[0][0] 
    end
    self
  end

  def self.create( name: , breed: )
    # binding.pry
     create_deg = Dog.new( name: name, breed: breed)
    create_deg.save
  end

  def self.new_from_db(row)
    # binding.pry
    dog = self.new(id: row[0], name: row[1], breed: row[2])
    
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
        LIMIT 1
    SQL
    results = DB[:conn].execute(sql, id).map do |row|  self.new_from_db(row) 
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    results = DB[:conn].execute(sql,name)[0]
    new_from_db(results) 
  end

  def self.find_or_create_by(name:, breed: )
  
      sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE name = ? AND breed = ?
        LIMIT 1
     SQL

    results = DB[:conn].execute(sql, name, breed).flatten 
    if results.empty?
      self.create( name: name, breed: breed)
    else
      self.new_from_db(results)
    end
  end

end

