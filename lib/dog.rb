class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
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
      DROP TABLE dogs
      SQL

      DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    end

    sql = <<-SQL
    INSERT INTO dogs
    (name, breed)
    VALUES
    (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.create(hash)
    new_dog = Dog.new(name: hash[:name], breed: hash[:breed])
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id == ?
      LIMIT 1
      SQL

      DB[:conn].execute(sql, id).collect do |row|
        self.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_or_create_by(name:, breed:)
    # if !self.find_by_name(name)
    #   puts "A"
    #   self.create
    # else
    #   puts "B"
    #   self.find_by_name(name)
    # end
    binding.pry
    if self.id
      self.find_by_id(id)
    else
      self.create

    end

  end

  def self.find_by_name(name)

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name == ?
      LIMIT 1
      SQL

      DB[:conn].execute(sql, name).collect do |row|
        self.new_from_db(row)
      end.first

  end

end
