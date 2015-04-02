require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
  should belong_to(:user)
  should belong_to(:friend)

  test "that creating a friendship works without raising an exception" do
    assert_nothing_raised do    
      UserFriendship.create user: users(:mul), friend: users(:jck)
    end    
  end

  test "that creating a friendship based on user id and friend id works" do
    UserFriendship.create user_id: users(:mul).id, friend_id: users(:jck).id
    assert users(:mul).pending_friends.include?(users(:jck))
  end

  context "a new instance" do
    setup do
      @user_friendship = UserFriendship.new user: users(:mul), friend: users(:gaby)
    end
    
    should "have a pending state" do
      assert_equal 'pending', @user_friendship.state
    end
  end

  context "#send_request_email" do
    setup do
      @user_friendship = UserFriendship.create user: users(:mul), friend: users(:gaby)
    end
    
    should "send an email" do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        @user_friendship.send_request_email
      end
    end
  end
  
  context "#mutual_friendship" do
    setup do
      UserFriendship.request users(:mul), users(:gaby)
      @friendship1 = users(:mul).user_friendships.where(friend_id: users(:gaby).id).first
      @friendship2 = users(:gaby).user_friendships.where(friend_id: users(:mul).id).first
    end
    
    should "correctly find the mutual friendship" do
      assert_equal @friendship2, @friendship1.mutual_friendship
    end
  end
  
  context "#accept_mutual_friendship!" do
    setup do
      UserFriendship.request users(:mul), users(:gaby)
    end
    
    should "accept the mutual friendship" do
      friendship1 = users(:mul).user_friendships.where(friend_id: users(:gaby).id).first
      friendship2 = users(:gaby).user_friendships.where(friend_id: users(:mul).id).first
      
      friendship1.accept_mutual_friendship!
      friendship2.reload
      assert_equal "accepted", friendship2.state
    end
  end
  
  context "#accept!" do
    setup do
      @user_friendship = UserFriendship.request users(:mul), users(:gaby)
    end
    
    should "set the state to accepted" do
      @user_friendship.accept!
      assert_equal "accepted", @user_friendship.state
    end
    
    should "send an acceptance email" do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        @user_friendship.accept!
      end
    end
    
    should "include the friend in the list of friends" do
      @user_friendship.accept!
      users(:mul).friends.reload
      assert users(:mul).friends.include?(users(:gaby))
    end
    
    should "accept the mutual friendship" do
      @user_friendship.accept!
      assert_equal 'accepted', @user_friendship.mutual_friendship.state
    end
  end
  
  context ".request" do
    should "create two user friendships" do
      assert_difference "UserFriendship.count", 2 do
        UserFriendship.request(users(:mul), users(:gaby))
      end
    end
    
    should "send a friend request email" do
      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        UserFriendship.request(users(:mul), users(:gaby))
      end
    end
  end
  
  context "#delete_mutual_friendship!" do
    setup do
      UserFriendship.request users(:mul), users(:gaby)
      @friendship1 = users(:mul).user_friendships.where(friend_id: users(:gaby).id).first
      @friendship2 = users(:gaby).user_friendships.where(friend_id: users(:mul).id).first
    end
    
    should "delete the mutual friendship" do
      assert_equal @friendship2, @friendship1.mutual_friendship
      @friendship1.delete_mutual_friendship!
      assert !UserFriendship.exists?(@friendship2.id)
    end
  end
  
  context "on destroy" do
    setup do
      UserFriendship.request users(:mul), users(:gaby)
      @friendship1 = users(:mul).user_friendships.where(friend_id: users(:gaby).id).first
      @friendship2 = users(:gaby).user_friendships.where(friend_id: users(:mul).id).first
    end
    
    should "delete the mutual friendship" do
      @friendship1.destroy
      assert !UserFriendship.exists?(@friendship2.id)
    end
  end
end










