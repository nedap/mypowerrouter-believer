require 'spec_helper'

describe Believer::Connection do

  it 'should re-use connections' do
    env = Believer::Base.environment
    nr_of_connections_before = env.retrieve_connections.count
    expect(nr_of_connections_before).to eql 1

    Test::Artist.where(:name => 'Beatles')
    Test::Artist.create({:id => 1, :name => 'Beatles'})
    Test::Artist.where(:name => 'Beatles').update_all(:label => 'Ringo Starr')

    nr_of_connections_after = env.retrieve_connections.count
    expect(nr_of_connections_after).to eql nr_of_connections_before
  end

  it 'should create a new connection if one times-out' do
    env = Believer::Base.environment
    expect(env.retrieve_connections.count).to eql 1

    conn = env.retrieve_connections.first
    allow(conn).to receive(:execute) do
      sleep(2)
      return Cql::TimeoutError
    end

    begin
      Test::Artist.where(:name => 'Beatles').to_a
    rescue
      # Do nothing
    end
    Test::Artist.where(:name => 'Beatles').to_a

    env = Believer::Base.environment
    expect(env.retrieve_connections.count).to eql 2
  end

end