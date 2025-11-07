module Admin
  class ProductsController < ApplicationController
    before_action :set_product, only: %i[ show edit update destroy new_variant destroy_product_photo destroy_lifestyle_photo ]

    # GET /products
    def index
      @products = Product.includes(:variants).all
    end

    # GET /products/1
    def show
    end

    # GET /products/new
    def new
      @product = Product.new
      @product.variants.build
    end

    # GET /products/1/edit
    def edit
      @product.variants.build if @product.variants.none?
    end

    # POST /products
    def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to admin_products_path, notice: "Product was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def new_variant
    end

    # PATCH/PUT /products/1
    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Product was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /products/1
    def destroy
      @product.destroy!
      redirect_to admin_products_path, notice: "Product was successfully destroyed.", status: :see_other
    end

    # DELETE /admin/products/:id/product_photo
    def destroy_product_photo
      @product.product_photo.purge
      respond_to do |format|
        format.turbo_stream
        format.html { head :ok }
      end
    end

    # DELETE /admin/products/:id/lifestyle_photo
    def destroy_lifestyle_photo
      @product.lifestyle_photo.purge
      respond_to do |format|
        format.turbo_stream
        format.html { head :ok }
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find_by!(slug: params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.expect(product: [
        :active,
        :featured,
        :sample_eligible,
        :name,
        :description,
        :colour,
        :category_id,
        :product_photo,
        :lifestyle_photo,
        :slug,
        :position,
        :meta_title,
        :meta_description,
        :meta_image,
        variants_attributes: [
          [
            :id,
            :_destroy,
            :name,
            :sku,
            :pac_size,
            :price,
            :stock_quantity,
            :active,
            :position,
            :product_photo,
            :lifestyle_photo,
            :length_in_mm,
            :height_in_mm,
            :width_in_mm,
            :depth_in_mm,
            :weight_in_g,
            :volume_in_ml,
            :diameter_in_mm
          ]
        ],
        compatible_cup_sizes: []
      ])
    end
  end
end
