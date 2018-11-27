class Dog 
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table()
    sql =  <<-SQL 
    CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT, 
    breed TEXT
    );
    SQL
    DB[:conn].execute(sql) 
  end
  
  def self.drop_table
   sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(row)
      Dog.new(id:row[0], name:row[1], breed:row[2])
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(id:result[0], name:result[1], breed:result[2])
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
end
  
end