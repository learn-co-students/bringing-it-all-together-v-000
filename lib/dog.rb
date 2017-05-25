require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(args)
    args.each{|arg, val| self.send("#{arg}=", val)}
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (name, breed) VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, @name, @breed)
    # get the ID from the database with SELECT last_insert_rowid
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
    self # return an object not an ID
  end
  def update
    sql = <<-SQL
      UPDATE #{self.class.table_name} SET name = ?, breed = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql, @name, @breed, @id)
    self # return an object not an ID
  end

  # CLASS METHODS
  def self.create(args)
    self.new(args).save
  end
  # create object from row in DB
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  # get an object by its ID
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE id = ?;
    SQL
    DB[:conn].execute(sql, id).map{|row| self.new_from_db(row)}.first
  end
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ?;
    SQL
    DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
  end
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ? AND breed = ?;
    SQL
    res = DB[:conn].execute(sql, name, breed)
    if res.size > 0
      return res.map{|row| self.new_from_db(row)}.first
    else
      return self.create(name: name, breed: breed)
    end
  end
  # Genreate the table name
  def self.table_name
    "#{self.to_s.downcase}s"
  end
  # create the table
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS #{self.table_name} (
      id INTEGER PRIMARY key,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end
  # drop the table
  def self.drop_table
    DB[:conn].execute("DROP TABLE #{self.table_name}")
  end
end
