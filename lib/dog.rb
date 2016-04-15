class Dog
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  class << self
    def create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS
          dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
      SQL
      
      DB[:conn].execute(sql)
    end
    
    def drop_table
      sql = <<-SQL
        DROP TABLE dogs;
      SQL
      
      DB[:conn].execute(sql)
    end
    
    def new_from_db(row)
      dog = self.new(id: row[0], name: row[1], breed: row[2])
    end
    
    def create(atts)
      dog = self.new(name: atts[:name], breed: atts[:breed])
      dog.save
    end
    
    def find_by_id(id)
      sql = <<-SQL
        SELECT id, name, breed
        FROM dogs
        WHERE id = ?;
      SQL
      
      dog_data = DB[:conn].execute(sql, id).flatten
      new_from_db(dog_data)
    end
    
    def find_by_name(name)
      sql = <<-SQL
        SELECT id, name, breed
        FROM dogs
        WHERE name = ?;
      SQL
      
      dog_data = DB[:conn].execute(sql, name).flatten
      new_from_db(dog_data)
    end
    
    def find_or_create_by(name:, breed:)
      sql = <<-SQL
        SELECT id, name, breed
        FROM dogs
        WHERE name = ? AND breed = ?;
      SQL
      
      dog = DB[:conn].execute(sql, name, breed).flatten
      dog.empty? ? create(name: name, breed: breed) : new_from_db(dog)
    end
  end
  
  def save
    if self.id.nil?
      insert = <<-SQL
        INSERT INTO
          dogs (name, breed)
        VALUES
          (?, ?);
      SQL
      
      DB[:conn].execute(insert, self.name, self.breed )
      
      get_id = <<-SQL
        SELECT id
        FROM dogs
        ORDER BY id
        DESC
        LIMIT 1;
      SQL
      
      self.id = DB[:conn].execute(get_id)[0][0]
    else
      update = <<-SQL
        UPDATE name, breed
        SET ?, ?
        WHERE id = ?;
      SQL
      
      DB[:conn].execute(update, self.name, self.breed)
    end
    
    return self
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;  
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end