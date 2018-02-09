class Dog

  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id:nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY key,
      name TEXT,
      breed TEXT)
    SQL

    DB[:conn].execute (sql)
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
    INSERT INTO dogs(name, breed)
    VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name:name ,breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed:row[2], id:row[0])
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first
  end

end
