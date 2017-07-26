class Dog
  attr_accessor :name,:breed,:id
  def initialize(name: ,breed: ,id: nil )
     @name=name
     @breed=breed
     @id=id
  end
  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs
      ( id INTEGER PRIMARY KEY,
        name, TEXT,
        breed TEXT

      )
      SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql=<<-SQL
      DROP TABLE dogs
      SQL
    DB[:conn].execute(sql)
  end
  def save
    if self.id
      self.update
      self
    else
      sql=<<-SQL
       INSERT INTO dogs(name,breed) VALUES(?,?)
       SQL
       DB[:conn].execute(sql,@name,@breed)
       @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
     self
   end
   def update
     sql=<<-SQL
      UPDATE dogs SET name=?,breed=?
      WHERE id=?
      SQL
      DB[:conn].execute(sql,@name,@breed,@id)
   end
   def self.create(name:,breed:)
     dog = Dog.new(name: name ,breed:breed)
     dog.save
     dog
   end
   def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    dog=Dog.new(id:result[0], name:result[1], breed:result[2])
  end
  def self.find_by_name(name)
   sql = "SELECT * FROM dogs WHERE name = ?"
   result = DB[:conn].execute(sql, name)[0]
   dog=Dog.new(id:result[0], name:result[1], breed:result[2])
 end
 def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1;", name, breed)
    if !dog.empty?
      self.new_from_db(dog[0])
    else
      self.create(name: name, breed: breed)
    end
  end
  def self.new_from_db(row)
    self.new(id:row[0], name:row[1], breed:row[2])
 end
end
