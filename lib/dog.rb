require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  #---------Instance Methods-----------
  def save
    if id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
      DB[:conn].execute(sql, name, breed)
      self.id = DB[:conn].execute('SELECT last_insert_rowid()')[0][0]
      self
    end
  end

      def find_by_id
        #test
      end

  #-----------Class Methods-----------
  class << self
    def create_table
      sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name INTEGER,
      breed INTEGER
    )
    SQL
      DB[:conn].execute(sql)
    end

    def drop_table
      DB[:conn].execute('DROP TABLE IF EXISTS dogs')
    end

    def create(dog)
      Dog.new(dog).save
    end
  end
end
