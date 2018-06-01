require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  @@params = {:name => "",
              :breed => "",
              :id => nil
            }

  def initialize(params)
    @name = params[:name]
    @breed = params[:breed]
    @id = params[:id]
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
    sql = <<-SQL
                DROP TABLE IF EXISTS dogs
            SQL
            DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
      self
    else
      sql = <<-SQL
                  INSERT INTO dogs (name, breed)
                  VALUES (?,?)
              SQL
              DB[:conn].execute(sql, self.name, self.breed)

              resultset = DB[:conn].execute("SELECT * FROM dogs")
              @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
              Dog.new(id: resultset[0], name: resultset[1], breed: resultset[2])
              self
    end

  end

  def self.create(name:, breed:)
    @@params[:name] = name
    @@params[:breed] = breed
    new_dog = Dog.new(@@params)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def self.find_or_create_by(name:, breed:)
    new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !new_dog.empty?
      new_dog_data = new_dog[0]
      new_dog = Dog.new(id: new_dog_data[0], name: new_dog_data[1], breed: new_dog_data[2])
    else
      new_dog = self.create(name: name ,breed: breed)
    end
    new_dog
    end

  def self.new_from_db(row)
    if !row.empty?
        Dog.new(id: row[0], name: row[1], breed: row[2])
   end
  end

  def self.find_by_name(name)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    found_dog = self.find_by_id(result[0][0])
    found_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
