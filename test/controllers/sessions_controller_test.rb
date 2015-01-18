require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should login" do
    josh = users(:one)
    post :create, name: josh.name, password: 'secret'
    assert_redirected_to game_url
    assert_equal josh.id, session[:user_id]
  end
 
  test "should fail login" do
    josh = users(:one)
    post :create, name: josh.name, password: 'wrong'
    assert_redirected_to login_url
  end

  test "should logout" do
    delete :destroy
    assert_redirected_to users_url
  end
end
