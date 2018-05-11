class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_hash, id=nil)
    @name= dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(dog_hash)
    dog = self.new(dog_hash)
    dog.save
  end



  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,id)
    # .map do |dog|
    #   self.new_from_db(dog)
    # end.first
  end


end
