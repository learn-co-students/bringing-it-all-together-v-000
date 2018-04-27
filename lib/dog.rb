class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:,breed:, id: nil )
      @name = name
      @breed = breed
      @id = id
    end

    def create_table
      sql = <<-SQL
        CREATE TABLE dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL

      db[:conn].execute(sql)
    end
end
