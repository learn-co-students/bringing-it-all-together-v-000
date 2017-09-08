class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
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
    sql = 'DROP TABLE dogs'
    DB[:conn].execute(sql)
  end

  def save
    sql = 'INSERT INTO dogs (name, breed) VALUES (?,?)'
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].last_insert_row_id
    self
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).tap { |new_dog| new_dog.save }
  end

  def self.new_from_db(arr)
    self.new(id: arr[0], name: arr[1], breed: arr[2])
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM dogs WHERE id = ?'
    DB[:conn].execute(sql, id).map { |row| self.new_from_db(row) }.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?',
                            name, breed).flatten
    if !dog.empty?
      dog = self.new_from_db(dog)
    else
      dog = self.create(name: name, breed: breed)
    end
      dog

  end

  def self.find_by_name(name)
    sql = ' SELECT * FROM dogs WHERE name = ?'
    DB[:conn].execute(sql, name).map { |row| self.new_from_db(row) }.first
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
