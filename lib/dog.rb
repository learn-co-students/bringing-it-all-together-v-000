require 'pry'
class Dog
      attr_accessor :id,:name, :breed

  def initialize(id:nil,name:,breed:)
    @id =id
    @name = name
    @breed = breed
  end
  #binding.pry

  def self.create_table

  end

  def self.drop_table
    sql = 'DROP TABLE IF EXISTS dogs'
    DB[:conn].execute(sql)
  end

  def save
    sql = 'INSERT INTO dogs (name,breed) VALUES (?,?)'
    DB[:conn].execute(sql,self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]


  end

  def self.create(id=nil,name:,breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

    def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

    def self.find_by_name(name)
       sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
       DB[:conn].execute(sql,name).map do |row|
        self.new_from_db(row)
       end.first
    end

   def update
    sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"

 DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
#     describe '.find_by_id' do
#     it 'returns a new dog object by id' do
#       dog = Dog.create(name: "Kevin", breed: "shepard")

#       dog_from_db = Dog.find_by_id(1)

#       expect(dog_from_db.id).to eq(1)
#     end
#   end

end