# require_relative './test_helper'
require_relative '../lib/redb'

class ReDbTest < Minitest::Test
  def redb
    ReDb.new
  end

  def drop
    redb.drop_table('lol')
  end

  def test_it_can_create_and_read_a_table
    redb.create_table('lol')

    expected = redb.read_table('lol')
    assert_equal expected, {"0"=>{"table_name"=>"lol", "nextId"=>1}}

    drop
  end

  def test_it_can_create_read_and_drop_a_table
    redb.create_table('lol')

    expected = redb.read_table('lol')
    assert_equal expected, {"0"=>{"table_name"=>"lol", "nextId"=>1}}

    drop
  end

  def test_it_can_add_data
    redb.create_table('lol')
    redb.new_data('lol', {'test' => 'data'})
    redb.new_data('lol', {'test' => 'data'})

    expected = {"0"=>{"table_name"=>"lol", "nextId"=>1}, "2"=>{"test"=>"data"}}
    assert_equal expected, redb.read_table('lol')

    drop
  end

  def test_it_can_replace_data
    redb.create_table('lol')
    redb.new_data('lol', {'test' => 'data'})
    redb.new_data('lol', {'test' => 'data'})

    redb.update_table('lol', {'test' => 'replaced'})

    expected = {"0"=>{"table_name"=>"lol", "nextId"=>1}, "2"=>{"test"=>"replaced"}}
    assert_equal expected, redb.read_table('lol')

    drop
  end
end
