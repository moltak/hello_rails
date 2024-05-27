require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test '로그인 되있지 않은 유저는 index 페이지로 이동되야한다' do
    get users_path
    assert_redirected_to login_url
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test 'should redirect edit when not logged in' do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test '잘못된 유저가 왔을 때, edit로 리다이렉트 되야한다.' do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test '잘못된 유저가 왔을 때, update로 리다이렉트 되야한다.' do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test '웹을 통해 admin 속성을 변경할 수 없어야한다.' do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: { password: 'password',
                                                    password_confirmation: 'password',
                                                    admin: true } }
    # admin: true를 전송해도 admin 속성이 변경되지 않아야한다.
    assert_not @other_user.admin?
  end

  test '로그인 되있지 않으면 login_url로 리다이렉트 되야한다.' do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test '어드민이 아니면 root_url로 리다이렉트 되야한다.' do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
end

