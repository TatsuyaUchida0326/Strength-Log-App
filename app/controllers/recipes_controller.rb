class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  # GET /recipes
  def index
    @recipes = Recipe.all
  end

  # GET /recipes/:id
  def show
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
  end

  # GET /recipes/:id/edit
  def edit
  end

  # POST /recipes
  def create
    @recipe = Recipe.new(recipe_params)
    if @recipe.save
      redirect_to @recipe, notice: 'レシピが正常に作成されました。'
    else
      render :new
    end
  end

  # PATCH/PUT /recipes/:id
  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: 'レシピが正常に更新されました。'
    else
      render :edit
    end
  end

  # DELETE /recipes/:id
  def destroy
    @recipe.destroy
    redirect_to recipes_url, alert: 'レシピが正常に削除されました。'
  end
  
  def upload_image
    @recipe = Recipe.find(params[:id])
    if params[:recipe].present? && @recipe.images.attach(params[:recipe][:images])
      redirect_to @recipe, notice: '画像が正常にアップロードされました。'
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recipe_params
      params.require(:recipe).permit(:title, :description, :calories, :prep_time, :cook_time)
    end
    
    def image_params
      params.require(:recipe).permit(images: [])
    end
end
