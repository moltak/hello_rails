require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: '',
                                              email: 'foo@invalid',
                                              password: 'foo',
                                              password_confirmation: 'bar' } }
    assert_template 'users/edit'
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name = 'Foo Bar'
    email = 'foo@bar.comd'
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: '',
                                              password_confirmation: '' } }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test 'friendly forwarding은 첫번째 시도에만 적용되야한다' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)

    log_in_as(@user) # 두 번째 로그인 시도
    assert_redirected_to @user # 기대 결과: 다시 edit 페이지로 redirect 되지 않음
  end
end