require 'spec_helper'

describe Believer::Columns do

  it 'should be able to find columns with type' do
    cols = Test::Song.columns
    expect(cols.size).to eql 5
  end

  it 'should be able to find columns with type' do
    int_cols = Test::Song.columns_with_type(:integer)
    expect(int_cols).to eql [Test::Song.columns[:track_number]]

    string_cols = Test::Song.columns_with_type(:string)
    expect(string_cols.size).to eql 4

    counter_cols = Test::AlbumStatistics.columns_with_type(:counter)
    expect(counter_cols.size).to eql 2
    expect(counter_cols).to include Test::AlbumStatistics.columns[:sold]
    expect(counter_cols).to include Test::AlbumStatistics.columns[:produced]
  end

end