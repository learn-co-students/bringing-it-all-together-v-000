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
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute('DROP TABLE dogs;')
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end
end