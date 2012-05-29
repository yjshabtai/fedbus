class InvoicesController < ApplicationController
	before_filter permission_required(:invoices)
	
  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = params[:sort] ? Invoice.order(params[:sort]) : Invoice.order(" id DESC")
	
	@columns = ["id","total","status","payment","user_id","created_at"]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @invoices }
    end
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
    @invoice = Invoice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @invoice }
    end
  end

  # GET /invoices/1/edit
  def edit
    @invoice = Invoice.find(params[:id])
  end

  # PUT /invoices/1
  # PUT /invoices/1.json
  def update
    @invoice = Invoice.find(params[:id])

    respond_to do |format|
      if @invoice.update_attributes(params[:invoice])
        format.html { redirect_to @invoice, :notice => 'Invoice was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end
end
