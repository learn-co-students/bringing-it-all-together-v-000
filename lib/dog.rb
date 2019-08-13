class Dog 
  attr_accessor :id, :name, :breed 
  
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name 
    @breed = breed 
  end 

  def self.create_table
    sql =  <<-SQL
      SELECT dogs
      FROM sqlite_master 
      WHERE type='table'
      AND
      tble_name='dogs'
    SQL
    
    create_table =   <<-SQL 
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
    SQL
    
    #why does this conditional need an 'end' and can't be written on one line? 
    if sql.empty? ? self.drop_table : DB[:conn].execute(create_table)
    end
  end 

  def self.drop_table
    sql = <<-SQL 
      DROP TABLE dogs
        SQL
    DB[:conn].execute(sql)
  end 

  # def self.new_from_db(row)
  
  # end

  # def self.find_by_name(name)
  #   SELECT * FROM dog WHERE name = ?
  # end 

  # def update
    
  # end 
  
  def save
    SELECT * FROM dog WHERE id = ?
    if 
      empty array
      INSERT
    else
      found to exist
      UPDATE      
    end
  end
end