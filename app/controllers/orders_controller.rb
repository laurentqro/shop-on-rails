class OrdersController < ApplicationController
  before_action :find_order, only: [:show]

  def show
  end

  def index
    if authenticated?
      @orders = Current.user.orders.recent.includes(:order_items, :products)
    else
      redirect_to root_path, alert: "Please sign in to view your orders."
    end
  end

  private

  def find_order
    @order = Order.find(params[:id])

    unless can_view_order?(@order)
      redirect_to root_path, alert: "You don't have permission to view this order."
    end
  end

  def can_view_order?(order)
    authenticated? && order.user == Current.user
  end
end
