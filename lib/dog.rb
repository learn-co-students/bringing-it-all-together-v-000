class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: id, name: name, breed: breed)
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
    #bai bai doggos
  end

  def save
    if self.id
       self.update
     elsif
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name: name, breed: breed)
    new_fuzzy = self.new(name: name, breed: breed)
    new_fuzzy.save
    new_fuzzy
  end

  def self.find_by_id(id)
    # sql = <<-SQL
    #   SELECT *
    #   FROM dogs
    #   WHERE id = ?
    #   LIMIT 1
    # SQL
    # DB[:conn].execute(sql, id).map do |dog_row|
    #   self.new_from_db(dog_row)
    # end.first
    sql = "SELECT * FROM dogs WHERE id = ?"
    match = DB[:conn].execute(sql, id)[0]
    Dog.new(id: match[0], name: match[1], breed: match[2])
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_fuzzy = self.new(id: id, name: name, breed: breed)
    new_fuzzy
  end

  def self.find_or_create_by(name: name, breed: breed)
    puppy = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    # why no hash for the above interpolation?
    if !puppy.empty?
      puppy_info = puppy[0]
      puppy = Dog.new(id: puppy_info[0], name: puppy_info[1], breed: puppy_info[2])
    else
      puppy = self.create(name: name, breed: breed)
    end
    puppy
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |dog_row|
      self.new_from_db(dog_row)
    end.first
  end
end
