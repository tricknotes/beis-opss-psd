class Investigations::ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper
  include InvestigationsHelper

  before_action :set_investigation
  before_action :set_product, only: %i[link remove unlink]
  before_action :set_countries, only: %i[new]

  def index
    @breadcrumbs = build_breadcrumb_structure
  end

  # GET /cases/1/products/new
  def new
    authorize @investigation, :update?
    @product_form = ProductForm.new
  end

  # POST /cases/1/products
  def create
    authorize @investigation, :update?

    @product_form = ProductForm.new(product_params)

    respond_to do |format|
      if @product_form.valid?
        AddProductToCase.call!(
          @product_form.serializable_hash.merge(investigation: @investigation, user: current_user)
        )
        format.html { redirect_to_investigation_products_tab success: "Product was successfully created." }
        format.json { render :show, status: :created, location: @investigation }
      else
        set_countries
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cases/1/products/2
  def link
    authorize @investigation, :update?
    @investigation.products << @product
    redirect_to_investigation_products_tab success: "Product was successfully linked."
  end

  def remove
    authorize @investigation, :update?
  end

  # DELETE /cases/1/products
  def unlink
    authorize @investigation, :update?
    RemoveProductFromCase.call(investigation: @investigation, product: @product, user: current_user)
    respond_to do |format|
      format.html do
        redirect_to_investigation_products_tab success: "Product was successfully removed."
      end
      format.json { head :no_content }
    end
  end

private

  def redirect_to_investigation_products_tab(flash)
    redirect_to investigation_products_path(@investigation), flash: flash
  end

  def set_investigation
    investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    @investigation = investigation.decorate
  end
end
