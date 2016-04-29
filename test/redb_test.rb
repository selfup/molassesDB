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
    redb.new_data('lol', {'test' => 'data1'})
    redb.new_data('lol', {'test' => 'data2'})

    expected = {
      "0"=>{"table_name"=>"lol", "nextId"=>3}, "1"=>{"test"=>"data1"}, "2"=>{"test"=>"data2"}
    }
    assert_equal expected, redb.read_table('lol')

    drop
  end

  def test_it_can_replace_data
    redb.create_table('lol')
    redb.new_data('lol', {'test' => 'data1'})
    redb.new_data('lol', {'test' => 'data2'})

    redb.update_table('lol', {'test' => 'replaced'})

    expected = {"0"=>{"table_name"=>"lol", "nextId"=>1}, "1"=>{"test"=>"replaced"}}
    assert_equal expected, redb.read_table('lol')

    drop
  end
  
  def test_it_can_execute_a_where_satement_like_rejs_with_ids_too
    redb.create_table('lol')
    redb.new_data('lol', {'test' => 'data1'})
    redb.new_data('lol', {'test' => 'data2'})
    redb.new_data('lol', {'test' => 'data1'})
    
    expected = [["1", {"test"=>"data1"}], ["3", {"test"=>"data1"}]]
    assert_equal expected, redb.where('lol', 'data1')

    drop
  end
end
