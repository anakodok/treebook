require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase
  context "#new" do
    context "when not logged in" do
      should "redirect to the login page" do
        get :new
        assert_response :redirect
      end    
    end

    context "when logged in" do
      setup do
        sign_in users(:mul)
      end
      
      should "get new and return success" do
        get :new
        assert_response :success
      end

      should "should set a flash error message if the friend_id param is missing" do
        get :new, {}
        assert_equal "Friend required", flash[:error]
      end

      should "display the friend's name" do
        get :new, friend_id: users(:jck)
        assert_match /#{users(:jck).fullname}/, response.body
      end
      
      should "assign a new user friendship" do
        get :new, friend_id: users(:jck)
        assert assigns(:user_friendship)
       end

      should "assign a new user friendship to the correct friend" do
        get :new, friend_id: users(:jck)
        assert_equal users(:jck), assigns(:user_friendship).friend
       end

      should "assign a new user friendship to the currently logged in user" do
        get :new, friend_id: users(:jck)
        assert_equal users(:mul), assigns(:user_friendship).user
       end

      should "returns a 404 status if no friend is found" do
        get :new, friend_id: 'invalid'
        assert_response :not_found
      end 

      should "ask if you really want to friend with the user" do
        get :new, friend_id: users(:jck)
        assert_match /Do you really want to friend #{users(:jck).fullname}?/, response.body
      end 
    end
  end
end
