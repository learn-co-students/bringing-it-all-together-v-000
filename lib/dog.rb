class Dog

  attr_accessor :id, :name, :breed

  def initialize(dog_info)
    @id = dog_info[:id]
    @name = dog_info[:name]
    @breed = dog_info[:breed]
  end

  def self.create_table
    sql =<<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def self.create(name:, breed:)
    new_dog = self.new(name, breed)
    new_dog.save
    new_dog
  end

  def save
    if self.id
      self.update
    else
      sql =<<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
      self
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    dog_data = DB[:conn].execute('SELECT * FROM dogs WHERE name = ?', name)[0]
    self.new_from_db(dog_data)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
