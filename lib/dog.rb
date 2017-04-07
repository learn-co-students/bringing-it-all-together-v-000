class Dog 
  attr_accessor :name, :breed, :id 

  def initialize(attributes)
    @name = attributes[:name]
    @breed = attributes[:breed]
    @id = nil
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save 
    sql = <<-SQL 
      INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.create(attrs)
    self.new(attrs).save
  end

  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE id = ?;
    SQL
    row = DB[:conn].execute(sql, id)[0]
    row.length == 0 ? nil : self.reifyRow(row)
  end

  def self.reifyRow(row)
    newOb = self.new({name: row[1], breed: row[2]})
    newOb.id = row[0]
    newOb
  end

  def self.find_or_create_by(dog)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    found = DB[:conn].execute(sql, dog[:name], dog[:breed])[0]
    if found.length == 0 
      self.create(dog)
    else
      self.reifyRow(found)
    end
  end 
  
end