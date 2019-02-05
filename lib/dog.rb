class Dog
  attr_accessor :name, :breed, :id
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INT PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end
  
  #def self.new_from_db
  #  sql = <<-SQL
  #    SELECT *
  #    FROM dogs
  #  SQL
  #end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() from DOGS;")[0][0]
    self
  end
  
end