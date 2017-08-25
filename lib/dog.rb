# # first attempt 8/17/17
# class Dog
#
#   attr_accessor :name, :breed
#   attr_reader :id
#
#   def initialize(name:, breed:, id: nil)
#     @name = name
#     @breed = breed
#     @id = id
#   end
#
#   def self.create_table
#     sql = <<-SQL
#       CREATE TABLE IF NOT EXISTS dogs (
#         id INTEGER PRIMARY KEY,
#         name TEXT,
#         breed TEXT
#       );
#     SQL
#
#     DB[:conn].execute(sql)
#   end
#
#   def self.drop_table
#     sql = <<-SQL
#       DROP TABLE IF EXISTS dogs;
#     SQL
#
#     DB[:conn].execute(sql)
#   end
#
#   def save
#     if self.id
#       self.update
#     else
#       sql = <<-SQL
#         INSERT INTO dogs (name, breed)
#         VALUES (?, ?);
#       SQL
#
#       DB[:conn].execute(sql, self.name, self.breed)
#       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
#     end
#     self
#   end
#
#   def update
#     sql = <<-SQL
#       UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
#     SQL
#
#     DB[:conn].execute(sql, self.name, self.breed, self.id)
#   end
#
#   def self.create(name:, breed:)
#     self.new(name: name, breed: breed).tap {|new_dog| new_dog.save}
#   end
#
#   def self.find_by_name(name)
#     sql = <<-SQL
#       SELECT * FROM dogs WHERE name = ?;
#     SQL
#
#     DB[:conn].execute(sql, name).each.map do |dog|
#       self.new_from_db(dog)
#     end.first
#   end
#
#   def self.find_by_id(id)
#     sql = <<-SQL
#       SELECT * FROM dogs WHERE id = ?;
#     SQL
#
#     DB[:conn].execute(sql, id).each.map do |dog|
#       self.new_from_db(dog)
#     end.first
#   end
#
#   def self.new_from_db(row)
#     self.new(id: row[0], name: row[1], breed: row[2])
#   end
#
#   def self.find_or_create_by(name:, breed:)
#     sql = <<-SQL
#       SELECT * FROM dogs WHERE name = ? AND breed = ?;
#     SQL
#
#     dog = DB[:conn].execute(sql, name, breed)
#
#     if !dog.empty?
#       dog_data = dog[0]
#       dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
#     else
#       dog = self.create(name: name, breed: breed)
#     end
#     dog
#   end
#
#
# end #end of Dog class

# second attempt 8/25/17
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
      CREATE TABLE IF NOT EXISTS dogs(
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
    self.persisted? ? self.update : self.insert
  end

  def persisted?
    # need the double bang in order to get the real T/F values
    !!self.id
  end

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).tap {|new_dog| new_dog.save}
  end

  def self.find_by_id(id_num)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id_num).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      data = dog[0]
      dog = self.new_from_db(data)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

end
