require File.dirname(__FILE__) + '/../spec_helper'

describe Stamp do
  describe "month points" do
    before(:each) do
      @stamp = Factory(:stamp)
      @stamp.marks.create!(:marked_on => "2010-01-01")
    end
    
    it "should be zero if no marks" do
      @stamp.month_points(Date.new(2009, 1)).should == [0] * 31
    end
    
    it "should be 1 on first mark but -1 on next miss" do
      @stamp.marks.create!(:marked_on => "2009-02-01")
      @stamp.month_points(Date.new(2009, 2)).should == [1, -1] + [0]*26
    end
    
    it "should build up points and tear down points" do
      ["2009-04-01", "2009-04-02", "2009-04-03", "2009-04-04", "2009-04-07"].each do |date|
        @stamp.marks.create!(:marked_on => date)
      end
      @stamp.month_points(Date.new(2009, 4, 3)).should == [1, 2, 2, 3, -1, -2, 1, -1, -2, -2, -1] + [0]*19
    end
    
    it "should apply score to previous month" do
      ["2009-03-31", "2009-04-01"].each do |date|
        @stamp.marks.create!(:marked_on => date)
      end
      @stamp.month_points(Date.new(2009, 4, 3)).should == [2, -1, -2] + [0]*27
    end
    
    it "should have points for a specific day" do
      @stamp.marks.create!(:marked_on => "2009-04-01")
      @stamp.day_points(Date.new(2009, 4, 2)).should == -1
    end
    
    it "should be 1 on first mark but -1 on next miss" do
      @stamp.marks.create!(:marked_on => "2009-04-01")
      @stamp.marks.create!(:marked_on => "2009-04-02", :skip => true)
      @stamp.month_points(Date.new(2009, 4)).should == [1, 0, -1] + [0]*27
    end
    
    it "should not subtract points after last mark" do
      Mark.delete_all
      @stamp.marks.create!(:marked_on => "2009-04-01")
      @stamp.marks.create!(:marked_on => "2009-04-02")
      @stamp.month_points(Date.new(2009, 4)).should == [1, 2] + [0]*28
    end
    
    it "should not subtract points after last mark on previous month" do
      Mark.delete_all
      @stamp.marks.create!(:marked_on => "2009-03-31")
      @stamp.month_points(Date.new(2009, 4)).should == [0]*30
    end
    
    it "should not subtract points when skip is later" do
      Mark.delete_all
      @stamp.marks.create!(:marked_on => "2009-04-01")
      @stamp.marks.create!(:marked_on => "2009-04-02")
      @stamp.marks.create!(:marked_on => "2009-04-10", :skip => true)
      @stamp.month_points(Date.new(2009, 4)).should == [1, 2] + [0]*28
    end
    
    it "should only take into account first mark if there are multiple on same day" do
      Mark.delete_all
      @stamp.marks.create!(:marked_on => "2009-04-01")
      @stamp.marks.create!(:marked_on => "2009-04-02", :skip => true)
      @stamp.marks.create!(:marked_on => "2009-04-02")
      @stamp.reload.month_points(Date.new(2009, 4)).should == [1] + [0]*29
      @stamp.score_cache.should == 1
    end
    
    it "should work with just one skip" do
      Mark.delete_all
      @stamp.marks.create!(:marked_on => "2009-04-02", :skip => true)
      @stamp.reload.month_points(Date.new(2009, 4)).should == [0]*30
      @stamp.score_cache.should == 0
    end
  end
  
  it "should use score cache if there is one" do
    stamp = Stamp.new
    stamp.score_cache = 123
    stamp.score.should == 123
  end
  
  it "should calculate score and set cache" do
    stamp = Factory(:stamp)
    stamp.marks.create!(:marked_on => "2009-01-01")
    stamp.marks.create!(:marked_on => "2009-01-02")
    stamp.score.should == 3
    stamp.reload.score_cache.should == 3
  end
  
  it "should have zero score if no marks" do
    Stamp.new.score.should be_zero
  end
  
  it "should default color to 'red'" do
    Stamp.new.color.should == "red"
  end
  
  it "should default goal_score to 100 when not set" do
    Factory(:stamp, :goal_score => "").goal_score.should == 100
  end
  
  it "should have a goal progress as percentage" do
    Factory(:stamp, :score_cache => 5, :goal_score => 10).goal_progress.should == 50
  end
  
  it "should not have goal progress go above 100" do
    Factory(:stamp, :score_cache => 15, :goal_score => 10).goal_progress.should == 100
  end
end
