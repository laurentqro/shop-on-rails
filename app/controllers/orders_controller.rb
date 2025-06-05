class OrdersController < ApplicationController
  before_action :require_authentication

  before_action :set_order, only: [ :show ]

  def show
  end

  def index
    @orders = Current.user.orders.recent.includes(:order_items, :products)
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end