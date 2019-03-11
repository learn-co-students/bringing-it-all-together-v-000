class Dog
attr_accessor :name, :breed
attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
       id INTEGER PRIMARY KEY,
       name TEXT,
       breed TEXT
    )"
    DB[:conn].execute(sql)
  end

  def self.drop_table
   sql = "DROP TABLE dogs"
   DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  #def self.create(name, breed)
    #self.new(name, grade)
    #self.save
    #self
  #end
end
