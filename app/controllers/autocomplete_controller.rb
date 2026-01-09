class AutocompleteController < ApplicationController
  def celebrities
    query = params[:q] || ""
    @celebrities = Celebrity.search(query).limit(10)
    
    render json: @celebrities.map { |c| { id: c.id, name: c.name } }
  end
end

