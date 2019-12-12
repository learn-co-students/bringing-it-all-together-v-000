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
  
  def save 
    def self.save(name:, type:, db:)
    db.execute( "INSERT INTO pokemon (name, type) VALUES (?, ?)", [name, type])
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM pokemon")[0][0]
  end
  

end