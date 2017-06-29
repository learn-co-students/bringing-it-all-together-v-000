class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self::create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )"
    DB[:conn].execute(sql)
  end

  def self::drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self::create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end

  def self::find_by_id
    sql = "SELECT * FROM dogs where id = ?"
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end



  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

end
