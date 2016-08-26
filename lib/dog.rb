require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(arguments)
    @name = arguments[:name]
    @breed = arguments[:breed]
    @id = arguments[:id]
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS "#{self.table_name}" (
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
    if persisted? 
      update 
    else
      sql = <<-SQL
        INSERT INTO "#{self.class.table_name}" (name, breed)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def persisted?
    !!self.id
  end

  def update
    sql = <<-SQL
      UPDATE "#{self.class.table_name}" SET name = ?, breed = ?, WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * 
    FROM "#{self.table_name}"
    WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)
    self.new_from_db(row.first)
  end

  def self.find_or_create_by(arguments)
    if 
      sql =<<-SQL
        SELECT * 
        FROM "#{self.table_name}"
        WHERE name = ? 
      SQL

      row = DB[:conn].execute(sql, arguments[:name])
      row
    else
      self.create
    end
  end

  def self.new_from_db(row)
   self.new(:name => row[1], :breed => row[2], :id => row[0])
  end
end 