require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
	test "db dump" do
		puts User.all.count
		assert true
	end
  # test 'login with invalid information' do
  #  get root_get
  #  assert_template 'index'
  #  post root_post, params: { homepage: { email: 'fsd@f', password: 'fds' } }
  #  assert_template 'index'
  #  assert_not flash.empty?
  #  get root_get
  #  assert flash.empty?
  #end
end
