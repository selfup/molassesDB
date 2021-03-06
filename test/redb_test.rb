require_relative './test_helper'
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

  def test_it_can_update_multiple_tables
    redb.create_table('lol')
    redb.create_table('omg')
    redb.create_table('wtf')

    redb.new_data('lol', {'test' => 'old data'})
    redb.new_data('omg', {'test' => 'old data'})
    redb.new_data('wtf', {'test' => 'old data'})

    redb.update_tables(
      ['lol', {'test' => 'new data'}],
      ['omg', {'test' => 'new data'}],
      ['wtf', {'test' => 'new data'}]
    )

    expected1 = {"0"=>{"table_name"=>"lol", "nextId"=>1}, "1"=>{"test"=>"new data"}}
    expected2 = {"0"=>{"table_name"=>"omg", "nextId"=>1}, "1"=>{"test"=>"new data"}}
    expected3 = {"0"=>{"table_name"=>"wtf", "nextId"=>1}, "1"=>{"test"=>"new data"}}

    assert_equal expected1, redb.read_table('lol')
    assert_equal expected2, redb.read_table('omg')
    assert_equal expected3, redb.read_table('wtf')

    redb.drop_table('lol')
    redb.drop_table('omg')
    redb.drop_table('wtf')
  end

  def test_it_can_create_multiple_tables
    redb.create_tables('lol', 'omg', 'rofl', 'lmao', 'wtf')

    assert redb.drop_table('lol')
    assert redb.drop_table('omg')
    assert redb.drop_table('rofl')
    assert redb.drop_table('lmao')
    assert redb.drop_table('wtf')
  end

  def test_it_can_drop_multiple_tables
    redb.create_tables('lol', 'omg', 'rofl', 'lmao', 'wtf')

    assert redb.drop_tables('lol', 'omg', 'rofl', 'lmao', 'wtf')
  end

  def test_it_can_add_data_to_more_than_one_table
    redb.create_tables('lol', 'omg')

    redb.new_datas(
      ['lol', {'testing' => 'fresh data'}],
      ['omg', {'testing' => 'fresh data'}]
    )

    expected1 = {"0"=>{"table_name"=>"lol", "nextId"=>2}, "1"=>{"testing"=>"fresh data"}}
    expected2 = {"0"=>{"table_name"=>"omg", "nextId"=>2}, "1"=>{"testing"=>"fresh data"}}

    assert_equal expected1, redb.read_table('lol')
    assert_equal expected2, redb.read_table('omg')

    redb.drop_tables('lol', 'omg')
  end

  def test_it_can_read_from_more_than_one_table
    redb.create_tables('lol', 'omg')

    redb.new_datas(
      ['lol', {'testing' => 'fresh data'}],
      ['omg', {'testing' => 'fresh data'}]
    )

    expected = [
      {"0"=>{"table_name"=>"lol", "nextId"=>2}, "1"=>{"testing"=>"fresh data"}},
      {"0"=>{"table_name"=>"omg", "nextId"=>2}, "1"=>{"testing"=>"fresh data"}}
    ]

    assert_equal Array, redb.read_tables('lol', 'omg').class
    assert_equal expected, redb.read_tables('lol', 'omg')

    redb.drop_tables('lol', 'omg')
  end

  def test_it_can_perform
    a = Time.now
    redb.create_tables('lol', 'omg')
    1000.times do
      redb.read_tables('lol', 'omg')
    end
    redb.drop_tables('lol', 'omg')
    puts Time.now - a
  end

  def test_it_can_add_and_read_a_good_amount_of_data
    a = Time.now
    redb.create_tables('lol', 'omg')
    1000.times do
      redb.new_datas(
        ['lol', {'testing' => 'fresh data'}],
        ['omg', {'testing' => 'fresh data'}]
      )
    end
    redb.read_tables('lol', 'omg')
    redb.drop_tables('lol', 'omg')
    puts Time.now - a
  end
end
