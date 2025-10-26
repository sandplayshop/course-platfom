class Admin::CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  def index
    @courses = Course.all
  end

  def show
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to admin_course_path(@course), notice: '課程已成功創建。'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to admin_course_path(@course), notice: '課程已成功更新。'
    else
      render :edit
    end
  end

  def destroy
    @course.destroy
    redirect_to admin_courses_url, notice: '課程已成功刪除。'
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, :price, :point_cost, :lesson_point_cost, :viewing_period_days)
  end
end

