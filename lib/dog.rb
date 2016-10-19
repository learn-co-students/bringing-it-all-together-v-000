class Dog
  attr_accessor :id, :name, :breed

  def initialize (dog_hash)
    @id = dog_hash[:id]
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
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
     self 
   end

   def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create (dog_hash)
    newdog = self.new(dog_hash)
    newdog.save
  end

  def self.find_by_id(idx)
    sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
    row = DB[:conn].execute(sql,idx)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL
      search_dog = DB[:conn].execute(sql,dog_hash[:name],dog_hash[:breed])[0]

      if search_dog
        self.find_by_id(search_dog[0])
      else
        self.create(dog_hash)
      end
  end

  def self.new_from_db(row)
   dog_hash = {:id=> row[0], :name => row[1], :breed => row[2]}
    self.new(dog_hash)  
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? 
      SQL
      search_dog = DB[:conn].execute(sql,name)[0]
      self.new_from_db(search_dog)
  end
end #of class Dog