module Admin
  class CategoriesController < ApplicationController
    before_action :set_category, only: %i[ edit update destroy ]

    # GET /admin/categories
    def index
      @categories = Category.order(:name)
    end

    # GET /admin/categories/new
    def new
      @category = Category.new
    end

    # GET /admin/categories/:id/edit
    def edit
    end

    # POST /admin/categories
    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_categories_path, notice: "Category was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /admin/categories/:id
    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Category was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/categories/:id
    def destroy
      @category.destroy!
      redirect_to admin_categories_path, notice: "Category was successfully deleted.", status: :see_other
    end

    private

    def set_category
      @category = Category.find_by!(slug: params[:id])
    end

    def category_params
      params.expect(category: [:name, :slug, :description, :meta_title, :meta_description, :image])
    end
  end
end
