require_relative '../config/environment'
DB[:conn] = SQLite3::Database.new ":memory:"

RSpec.configure do |config|
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  #you can do global before/after here like this:
  config.before(:each) do
    if Dog.respond_to?(:create_table)
      Dog.create_table
    else
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
      DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, color TEXT, breed TEXT, instagram TEXT)")
    end
  end

  config.after(:each) do
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
end

describe '::create_table' do
  it 'creates a dogs table' do
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
    Dog.create_table

    table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs';"
    expect(DB[:conn].execute(table_check_sql)[0]).to eq(['dogs'])
  end
end

describe '::drop_table' do
    it "drops the dogs table" do
        Dog.drop_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs';"
      expect(DB[:conn].execute(table_check_sql)[0]).to be_nil
    end
  end
