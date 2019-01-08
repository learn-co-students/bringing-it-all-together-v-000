require 'pry'

class Dog
  
  attr_accessor :name, :breed, :id
  
  def initialize(row)  
    @name= row[:name]
    @breed= row[:breed]
    @id= row[:id]
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
      SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1" 
      
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first 
  end
  
  def save
    
    DB[:conn].execute("INSERT INTO dogs VALUES (?, ?)", @name, @breed)
    
    # describe "#save" do
    # it 'returns an instance of the dog class' do
    #   dog = teddy.save

    #   expect(dog).to be_instance_of(Dog)
    # end

    # it 'saves an instance of the dog class to the database and then sets the given dogs `id` attribute' do
    #   dog = teddy.save

    #   expect(DB[:conn].execute("SELECT * FROM dogs WHERE id = 1")).to eq([[1, "Teddy", "cockapoo"]])
    #   expect(dog.id).to eq(1)
  end
  
  def update
  
  end
  
end  