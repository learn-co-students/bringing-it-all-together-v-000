class Dog
  attr_accessor :name, :breed, :id

  def initialize(attr_hash)
    @name = attr_hash[:name]
    @breed = attr_hash[:breed]
    @id = attr_hash[:id]
  end

  def self.create_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
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

  def self.new_from_db(dog_row)
    dog_hash = {
    :id =>  dog_row[0],
    :name => dog_row[1],
    :breed => dog_row[2]
    }

    doggo = Dog.new(dog_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = (?) LIMIT 1
    SQL

    dog_row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(dog_row)
  end

  def self.create(dog_hash)
    self.new(dog_hash).tap do |doggo|
      doggo.save
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = (?), breed = (?)
      WHERE id = (?)
    SQL
    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def persisted?
    !!@id
  end

  def save
    if persisted?
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL

      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end

    return self
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = (?) LIMIT 1
    SQL

    dog_row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(dog_row)
  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = (?) AND breed = (?) LIMIT 1
    SQL

    dog_row = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])[0]

    if dog_row
      self.new_from_db(dog_row)
    else
      self.new(dog_hash).save
    end
  end

end
