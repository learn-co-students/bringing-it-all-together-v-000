class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash)

    hash.each do |key,value|
      self.send(("#{key}="), value)
    end

  end

  def self.create_table

    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save

    if self.id
      update
    else

      sql = <<-SQL
      INSERT INTO dogs (name,breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql,self.name,self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(number)
    sql = <<-SQL
    SELECT * 
    FROM dogs
    WHERE id = ?
    SQL

    row = DB[:conn].execute(sql,number)[0]
    self.new_from_db(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * 
    FROM dogs
    WHERE name = ?
    SQL

    row = DB[:conn].execute(sql,name)[0]
    self.new_from_db(row)
  end

  def self.new_from_db(row)
    hash = {name: row[1], breed: row[2], id: row[0]}
    self.new(hash)

  end


  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    AND breed = ?
    SQL

    row = DB[:conn].execute(sql,name,breed)[0]
    if row != nil
      self.new_from_db(row)
    else
      hash = {name: name, breed: breed}
      self.create(hash)
    end
    
  end

  def update
    sql = <<-SQL
    UPDATE dogs 
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end




end