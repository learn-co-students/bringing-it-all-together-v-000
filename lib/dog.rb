class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    
    @id = id
    @name = name
    @breed = breed
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
      DROP TABLE dogs;
      SQL

      DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL 
      INSERT INTO dogs
      (name,breed)
      VALUES
      (?,?)
    SQL

    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

  end 

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL 
    SELECT * FROM dogs 
    WHERE id = ?
    SQL

    row = DB[:conn].execute(sql,id)[0]
    Dog.new(id: row[0],name: row[1],breed: row[2])

  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL 
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql,name,breed)

    if !row.empty?
      new_dog = row[0]
      dog = Dog.new(id: new_dog[0],name: new_dog[1],breed: new_dog[2])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(id: row[0],name: row[1],breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL 
    SELECT * FROM dogs
    WHERE name = ? 
    SQL
    row = DB[:conn].execute(sql,name)[0]

    Dog.new(id: row[0],name: row[1],breed: row[2])
  end


end