class Dog

  attr_accessor :id, :name, :breed

  def initialize(id=nil, dog)
    @id = id
    @name = dog[:name]
    @breed = dog[:breed]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IN NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name, TEXT,
      breed TEXT
    )
    SQL
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
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(dog)
    # binding.pry
    new_dog = Dog.new(dog)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    new_dog_details = [[:name, row[1]], [:breed, row[2]]].to_h
    new_dog = self.new(row[0], new_dog_details)
    new_dog
  end

  def self.find_or_create_by(dog)
    new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", dog[:name], dog[:breed])
    if !new_dog.empty?
      dog_data = new_dog[0]
      dog_details = [[:name, dog_data[1]], [:breed, dog_data[2]]].to_h
      new_dog = Dog.new(dog_data[0], dog_details)
    else
      new_dog = self.create(dog)
    end
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
