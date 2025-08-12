class Course < ApplicationRecord
  attr_accessor :name, :topic

  def initialize(params = {})
    @name = params[:name]
    @topic = params[:topic]
  end
end
