require 'spec_helper'

describe Zensu::Server::FailureDetector do

  it 'should have a low phi value after only a second' do
    time = 0
    0.upto(100) do |i|
      time += 1000
      subject.add(time)
    end

    subject.phi(time + 1000).should be < 0.5
  end

  #TODO fix this
  # it 'should have a high phi value after ten seconds' do
  #   time = 0
  #   0.upto(100) do |i|
  #     time += 1000
  #     subject.add(time)
  #   end

  #   subject.phi(time + 10000).should be > 4

  # end

  it 'should trim intervals to max size' do
    subject = described_class.new(nil, intervals_size: 3)
    time = 0
    0.upto(4) do |i|
      time += 1000
      subject.add(time)
    end

    subject.intervals.size.should == 3
  end

end
