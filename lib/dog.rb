require 'pry'
class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id =id
    @name = name
    @breed = breed
  end


  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS Dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
  sql = "DROP TABLE Dogs;"
   DB[:conn].execute(sql)
  end


  def save
      sql = <<-SQL
      INSERT INTO Dogs (name, breed)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()FROM dogs")[0][0]
      self
  end


   def self.create(name:,breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end


    def self.find_by_id(id)
      sql = "SELECT * FROM dogs WHERE id = ?"
      result = DB[:conn].execute(sql,id)[0]
      binding.pry
      Dog.new(result[0], result[1], result[2])
    end

   def find_or_create_by (name:, breed:)
      dog = DB [:conn].execute("SELECT * FROM dogs where name = ? AND breed = ?", name, album)
      if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
      else
        song = self.create(name:name, breed: breed)
      end
      dog
   end



   def self.new_from_db(row)
     self.new(row[0], row[1], row[2])
   end



  def self.find_by_name(name)
  sql = "SELECT * FROM dogs WHERE name = ?"
  result = DB[:conn].execute(sql,name)[0]
  Dog.new(result[0], result[1], result[2])
  end


   def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
