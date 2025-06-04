class Admin::ProductVariantsController < ApplicationController
  before_action :set_product_variant, only: [ :edit, :update ]

  def edit
  end

  def update
    if @product_variant.update(product_variant_params)
      redirect_to admin_product_variant_path(@product_variant), notice: "Product variant updated successfully"
    else
      render :edit
    end
  end

  private

  def set_product_variant
    @product_variant = ProductVariant.find(params[:id])
  end

  def product_variant_params
    params.expect(
      product_variant: [
        :name,
        :sku,
        :price,
        :active,
        :image,
        :width_in_mm,
        :height_in_mm,
        :depth_in_mm,
        :weight_in_g,
        :volume_in_ml,
        :diameter_in_mm
      ]
    )
  end
end
