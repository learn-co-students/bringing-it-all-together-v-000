class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize (name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
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
      DB[:conn].execute("DROP TABLE dogs")
   end

   def save
     if self.id
       self.update
     else
       sql = <<-SQL
       INSERT INTO dogs (name, breed) VALUES (?,?)
       SQL
       DB[:conn].execute(sql, self.name, self.breed)
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").first.first
     end
     self
   end

   def update
     sql = <<-SQL
     UPDATE dogs SET name = ?, breed = ? WHERE id = ?
     SQL
     DB[:conn].execute(sql, self.name, self.breed, self.id).first
   end

   def self.new_from_db (row)
     self.new({id:row[0], name:row[1], breed:row[2]})
   end

   def self.find_by_name(name)
     sql = <<-SQL
     SELECT * FROM dogs WHERE name = ?
     SQL
     #DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
     row = DB[:conn].execute(sql, name).first
     self.new_from_db(row)
   end

   def self.find_by_id(id)
     sql = <<-SQL
     SELECT * FROM dogs WHERE id = ?
     SQL
     #DB[:conn].execute( sql, id).map {|row| self.new_from_db(row)}.first
     row = DB[:conn].execute( sql, id).first
     self.new_from_db(row)
   end

   def self.create (name:, breed:)
     dog = self.new({name:name, breed:breed})
     dog.save
     dog
   end

   def self.find_or_create_by(name:, breed:)
     sql = <<-SQL
     SELECT * FROM dogs WHERE name = ? AND breed = ?
     SQL
     dog_data = DB[:conn].execute(sql, name, breed)
     if !dog_data.empty?
       dog_row = dog_data.first
       dog = self.new({id: dog_row[0], name: dog_row[1], breed: dog_row[2]})
     else
       dog = self.create(name:name, breed:breed)
     end
     dog
   end

end
