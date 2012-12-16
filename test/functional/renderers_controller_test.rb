require 'test_helper'

class RenderersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:renderers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create renderer" do
    assert_difference('Renderer.count') do
      post :create, :renderer => { }
    end

    assert_redirected_to renderer_path(assigns(:renderer))
  end

  test "should show renderer" do
    get :show, :id => renderers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => renderers(:one).to_param
    assert_response :success
  end

  test "should update renderer" do
    put :update, :id => renderers(:one).to_param, :renderer => { }
    assert_redirected_to renderer_path(assigns(:renderer))
  end

  test "should destroy renderer" do
    assert_difference('Renderer.count', -1) do
      delete :destroy, :id => renderers(:one).to_param
    end

    assert_redirected_to renderers_path
  end
end
