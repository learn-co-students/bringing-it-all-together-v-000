class Dog 
  
  attr_accessor :id, :name, :breed
  
 def initialize(id: nil, name: , breed: )
    @id = id 
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql =<<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY, 
      name TEXT, 
      type TEXT)
      SQL
      DB[:conn].execute(sql)
    end
    
  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs 
    SQL
    DB[:conn].execute(sql)
  end
  
  def save()
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dog")[0][0]
      DB[:conn].execute("SELECT * FROM dogs ORDER by id DESC LIMIT 1)
  end
end