require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path

    assert_template "sessions/new"
    post login_path, params: { session: { email: "", password: "" } }
    assert_response 422
    assert_template "sessions/new"
    assert_not flash.empty?

    get root_path
    assert flash.empty?
  end

  test "login test" do
    get login_path

    post login_path, params: { session: { email: @user.email, password: "password" } }
    assert_response 302
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    get logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "password" } }

    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    get logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url

    # 2번째 윈도우에서 로그아웃 시도 시뮬레이션
    get logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: "1")
    assert_equal true, assigns(:user).remember
  end

  test "login without remembering" do
    # 쿠키를 저장하고 로그인
    log_in_as(@user, remember_me: "1")
    get logout_path

    # 쿠키를 삭제하고 로그인
    log_in_as(@user, remember_me: "0")
    assert_empty cookies[:remember_token]
  end
end
