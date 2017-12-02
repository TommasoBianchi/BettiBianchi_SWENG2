class UserController < ApplicationController
  public
  def newSmallUser
    email = Email.create(params[:email])
    params.delate('email')
    @user.emails.push(email)
    @user.primary_email_id = email.id
    @user.name = 'Fede'
    @user.surname = 'Betti'
    @user.nicnkame = 'neobetti'
    @user.preference_list = '1302'
  end
end
