class ScoreTracker
  attr_reader :score, :position, :positive_points, :negative_points
  
  def initialize(options = {})
    @score = options[:score] || 0
    @positive_points = options[:positive_points] || 0
    @negative_points = options[:negative_points] || 0
    @position = options[:position] || 0
  end
  
  def mark
    if @negative_points > 0
      @negative_points = 0
      @position = 0
    end
    if @position >= @positive_points
      @positive_points += 1
      @position = 0
    end
    @position += 1
    @score += @positive_points
    @positive_points
  end
  
  def skip
    # keep scores as they are
    0
  end
  
  def miss
    @position = 0 if @negative_points.zero?
    if @position == @negative_points
      @positive_points -= 1 unless @positive_points.zero?
      @negative_points += 1
      @position = 0
    end
    @position += 1
    if @score < @negative_points
      @position = 0
      @negative_points = @score
    end
    @score -= @negative_points
    -@negative_points
  end
end
