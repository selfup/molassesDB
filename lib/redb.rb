require 'open-uri'

class ReDb
  def initialize
    return Dir.mkdir("redb") if !File.exist?("redb")
  end

  OPEN_AND_WRITE = -> (method, table_name) do
    return if File.exist?(table_name)
    File.open("./redb/#{table_name}", "w+"){|x| x.write(method)}
  end

  WHERE_PUSH = -> (x, query, queryReturn) do
    queryReturn << x if x[1].values.include?(query)
  end

  def create_table(table_name)
    OPEN_AND_WRITE.(meta_data(table_name), table_name)
  end

  def read_table(table_name)
    eval(File.open("./redb/#{table_name}", "r+").read)
  end

  def drop_table(table_name)
    File.delete("./redb/#{table_name}")
  end

  def new_data(table_name, data)
    table = read_table(table_name)
    table["#{table['0']['nextId']}"] = data
    table['0']['nextId'] += 1
    File.open("./redb/#{table_name}", "w+"){|x| x.write(table)}
  end

  def update_table(table_name, data)
    new_data = meta_data(table_name)
    new_data['1'] = data
    File.open("./redb/#{table_name}", "w+"){|x| x.write(new_data)}
  end

  def update_tables(*tables_and_data)
    tables_and_data.map {|x| update_table(x[0], x[1])}
  end

  def where(table_name, query)
    queryReturn = []
    read_table(table_name).map {|x| WHERE_PUSH.(x, query, queryReturn)}
    queryReturn
  end

  private

  def meta_data(table_name)
    {'0' => {'table_name' => "#{table_name}", 'nextId' => 1}}
  end
end
