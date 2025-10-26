class Admin::LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_lesson, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  def index
    @lessons = @course.lessons
  end

  def show
  end

  def new
    @lesson = @course.lessons.new
  end

  def create
    @lesson = @course.lessons.new(lesson_params)
    if @lesson.save
      redirect_to admin_course_lesson_path(@course, @lesson), notice: '課程單元已成功創建。'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @lesson.update(lesson_params)
      redirect_to admin_course_lesson_path(@course, @lesson), notice: '課程單元已成功更新。'
    else
      render :edit
    end
  end

  def destroy
    @lesson.destroy
    redirect_to admin_course_path(@course), notice: '課程單元已成功刪除。'
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_lesson
    @lesson = @course.lessons.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:title, :content)
  end
end

