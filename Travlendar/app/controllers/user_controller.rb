class UserController < ApplicationController

  class << self # Class methods
    def newSmallUser
      @user.name = 'Fede'
      @user.surname = 'Betti'
      @user.nicnkame = 'neobetti'
      @user.preference_list = '1302'
    end
      end

end
