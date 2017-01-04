class Dog

  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :breed => "TEXT"
  }

  ATTRIBUTES.keys.each do |attribute_name|
    attr_accessor attribute_name
  end

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
        end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name, breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(result[0], result[1], result[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = DB[:conn].execute("
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?,
    name, breed
    ")

    if !dog.empty?
      dog_data = dong[0]
      dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
    else
      song = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    self.new.tap do |d|
      ATTRIBUTES.keys.each.with_index do |attribute_name, i|
        d.send("#{attribute_name}=", row[i])
      end
    end
  end

end
