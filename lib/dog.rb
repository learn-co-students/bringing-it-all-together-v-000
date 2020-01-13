class Dog 
  attr_accessor :name, :breed
  attr_reader :id 
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
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
    DB[:conn].execute("DROP TABLE dogs")
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.create(hash)
    d = self.new(name: hash[:name], breed: hash[:breed])
    d.save
    d
  end
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_id(id)
    row = DB[:conn].execute("select * from dogs where id = ?", id)[0]
    self.new_from_db(row)
  end
  
  def self.find_by_name(name)
    row = DB[:conn].execute("select * from dogs where name = ?", name)[0]
    self.new_from_db(row)
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      select *
      from dogs
      where name = ? and breed = ?
    SQL
    row = DB[:conn].execute(sql, name, breed)[0]
    if row == nil
      self.create(name: name, breed: breed)
    else
      self.new_from_db(row)
    end
  end
  
  def update
    sql = <<-SQL
      update dogs
      set name = ?, breed = ?
      where id = ?
    SQL
    DB[:conn].execute(sql, @name, @breed, @id)
  end
  
end