class Dog

  attr_accessor :id, :name, :breed

  def initialize (id:nil, name:, breed:)
    self.id = id
    self.name = name
    self.breed = breed
  end

  def self.create_table
    sql = (<<-SQL)
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
      sql = (<<-SQL)
          INSERT INTO dogs(name, breed)
          VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

    def self.create(name:, breed:)
      dog = Dog.new(name:name, breed:breed)
      dog.save
      dog
    end

    def self.find_by_id(id)
      dog_info = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
      dog
    end

    def self.find_or_create_by(id:nil, name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
        dog_data = dog.first
        new_dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
      else
        new_dog = Dog.create(name:name, breed:breed)
      end
      new_dog
    end

    def self.new_from_db(info_array)
      dog = Dog.new(id: info_array[0], name: info_array[1], breed: info_array[2])
      dog
    end

    def self.find_by_name(name)
      dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      dog
    end
    
    def update
      sql = (<<-SQL)
          UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end