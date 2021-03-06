require 'spec_helper'

describe Believer::Querying do

  [
      {:method => :select, :args => [:name]},
      {:method => :where, :args => {:name => 'Beatles'}},
      {:method => :order, :args => :name},
      {:method => :limit, :args => 10},
  ].each do |scenario|
    it "#{scenario[:method]} call should return a query object" do
      expect(Test::Artist.send(scenario[:method], scenario[:args]).class).to eql Believer::Query
    end
  end

end