class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(hash)
    @id = hash[:id] || nil
    @name = hash[:name]
    @breed = hash[:breed]
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
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    return self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = <<-SQL
        DROP TABLE IF EXISTS dogs
      SQL
      DB[:conn].execute(sql)
    end

    def self.create(hash)
      new_dog = self.new(hash)
      new_dog.save
      return new_dog
    end

    def self.new_from_db(array)
      new_dog = self.new({id: array[0], name: array[1], breed: array[2]})
      return new_dog
    end

    def self.find_by_id(id)
      sql = 'SELECT * FROM dogs WHERE id = ?'
      DB[:conn].execute(sql, id).map{|s| self.new_from_db(s)}.first
    end

    def self.find_by_name(name)
      sql = 'SELECT * FROM dogs WHERE name = ?'
      DB[:conn].execute(sql, name).map{|s| self.new_from_db(s)}.first
    end

    def self.find_or_create_by(name: name, breed: breed)
      sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?'
      dog = DB[:conn].execute(sql, name, breed)
      if dog.empty?
        new_dog = self.create(name: name, breed: breed)
        return new_dog
      else
        old_dog = self.new_from_db(dog[0])
        return old_dog
      end
    end

end
