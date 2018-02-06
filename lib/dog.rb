
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize (id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY key,
        name TEXT,
        breed TEXT
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
      SQL

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
      DB[:conn].execute(sql,self.name,self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(sql,self.name, self.breed, self.id)
  end

  def self.create(attr_hash)
    new_pup = Dog.new(name: attr_hash[:name], breed: attr_hash[:breed])
    new_pup.save
    new_pup
  end

  def self.new_from_db(row)
    new_pup = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id_num)
    sql = <<-SQL
      SELECT * FROM dogs WHERE
      id = ?
      SQL
    row = DB[:conn].execute(sql,id_num).first

    self.new_from_db(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE
      name = ?
      SQL
    row = DB[:conn].execute(sql,name).first

    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE
      name = ? AND breed = ?
      SQL

    result_set = DB[:conn].execute(sql, name, breed)

    if !result_set.empty?
      dog_result = result_set[0]
      doggo = Dog.new(id:dog_result[0],name:dog_result[1],breed:dog_result[2])
    else
      doggo = self.create(name:name, breed:breed)
    end
    doggo
  end
end
