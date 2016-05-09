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
  end
 
  def self.create(name:,breed:)
    new_dog = Dog.new(name, breed)
    new_dog.save
  end

  #binding.pry


#   describe "#create" do
#     it 'takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database'do
#       Dog.create(name: "Ralph", breed: "lab")
#       expect(DB[:conn].execute("SELECT * FROM dogs")).to eq([[1, "Ralph", "lab"]])
#     end
#     it 'returns a new dog object' do
#       dog = Dog.create(name: "Dave", breed: "podle")

#       expect(teddy).to be_an_instance_of(Dog)
#       expect(dog.name).to eq("Dave")
#     end
#   end


end