class Dog
#==========================================
  attr_accessor :name, :breed, :id 
#=============initialize===================
  def initialize(attrs)
    attrs.each{|k, v| self.send(("#{k}="), v)}
  end
#================table=====================  
  def self.create_table
    DB[:conn].execute(<<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY, 
      name TEXT, 
      breed TEXT
      )
    SQL
    ) 
  end
  
  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs') 
  end
#==============creators==================== 
  def self.create(attrs)
    self.new(attrs).tap{|dog| dog.save}
  end
  
  def self.new_from_db(data)
    self.new({id: data[0], name: data[1], breed: data[2]})
  end
#==============finders====================   
  def self.find_by_id(id)
    new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ? LIMIT 1", id)[0])
  end
  
  def self.find_by_name(name)
    new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0])
  end
  
  def self.find_or_create_by(attrs)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    data = DB[:conn].execute(sql, attrs[:name], attrs[:breed])[0]
    
    data != nil ? new_from_db(data) : self.create(attrs)
  end
#===============instance===================
  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] and self
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
#==========================================
end