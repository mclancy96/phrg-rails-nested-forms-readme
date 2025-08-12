class StudentsController < ApplicationController
  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params[:student])

    @courses = []
    student_params[:student][:courses].each do |course_details|
      @courses << Course.new(course_details)
    end

    render :show
  end

  private

  def student_params
    params.permit(student: [:name, :grade, courses: [:name, :topic]])
  end
end
