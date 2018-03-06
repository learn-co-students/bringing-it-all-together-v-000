class Dog
attr_accessor :name, :breed, :id

  def initialize(keyword_hash)
    keyword_hash.each {|k, v| self.send(("#{k}="), v)}
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
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

    def update
      sql = ("UPDATE dogs SET name = ?, breed = ? WHERE id = ?")
      DB[:conn].execute(sql, self.name, self.breed, self.id)
      self
    end

    def self.create(attr_hash)
      dog = Dog.new(attr_hash)
      dog.save
      dog
    end

    def self.find_by_id(id_num)
      sql = ("SELECT * FROM dogs WHERE id = ?")
      new_dog = DB[:conn].execute(sql, id_num)

      new_dog_data = new_dog[0]
      new_dog_hash = {id: new_dog_data[0], name: new_dog_data[1], breed: new_dog_data[2]}
      #binding.pry
      new_dog = Dog.new(new_dog_hash)
    end

    def self.find_by_name(name_to_find)
      sql = ("SELECT * FROM dogs WHERE name = ?")
      new_dog = DB[:conn].execute(sql, name_to_find)

      new_dog_data = new_dog[0]
      new_dog_hash = {id: new_dog_data[0], name: new_dog_data[1], breed: new_dog_data[2]}
      #binding.pry
      new_dog = Dog.new(new_dog_hash)
    end

    def self.new_from_db(attr_array)
      new_dog_hash = {id: attr_array[0], name: attr_array[1], breed: attr_array[2]}
      new_dog = Dog.new(new_dog_hash)
    end

    def self.find_or_create_by(attr_hash)
      sql = ("SELECT * FROM dogs WHERE name = ? AND breed = ?")
      result = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed])
      #binding.pry
      if !result.empty?
        dog = new_from_db(result[0])
      else
        dog = Dog.create(attr_hash)
      end
      dog
    end

end
