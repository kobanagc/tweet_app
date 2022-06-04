require 'rails_helper'

RSpec.describe "register new user", type: :system do
  before do
    @user = FactoryBot.build(:user)
  end
  context "success in creating new user" do
    it "正しい情報を入力すればユーザー新規登録ができてトップページへ遷移する" do
      visit root_path
      expect(page).to have_content("新規登録")
      visit new_user_registration_path
      fill_in "Nickname", with: @user.nickname
      fill_in "Email", with: @user.email
      fill_in "Password", with: @user.password
      expect{
        find('input[name="commit"]').click
      }.to change { User.count}.by(1)
      expect(current_path).to eq(root_path)
      expect(
        find(".user_nav").find("span").hover
      ).to have_content("ログアウト")
      expect(page).to have_no_content("新規登録")
      expect(page).to have_no_content("ログイン")
    end
  end
  context "failer in creating new user" do
    it "誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる" do
      visit root_path
      expect(page).to have_content("新規登録")
      visit new_user_registration_path
      fill_in "Nickname", with: ""
      fill_in "Email", with: ""
      fill_in "Password", with: ""
      expect{
        find('input[name="commit"]').click
      }.to change { User.count }.by(0)
      expect(current_path).to eq user_registration_path
    end
  end
end

RSpec.describe "Login", type: :system do
  before do
    @user = FactoryBot.create(:user)
  end
  context "success in Log in" do
    it "保存されているユーザーの情報と合致すればログインができる" do
      visit root_path
      expect(page).to have_content("ログイン")
      visit new_user_session_path
      fill_in "Email", with: @user.email
      fill_in "Password", with: @user.password
      find('input[name="commit"]').click
      expect(current_path).to eq(root_path)
      expect(
        find(".user_nav").find("span").hover
      ).to have_content("ログアウト")
      expect(page).to have_no_content("新規登録")
      expect(page).to have_no_content("ログイン")
    end
  end
  context "failer in Log in" do
    it "保存されているユーザーの情報と合致しないとログインができない" do
      visit root_path
      expect(page).to have_content("ログイン")
      visit new_user_session_path
      fill_in "Email", with: ""
      fill_in "Password", with: ""
      find('input[name="commit"]').click
      expect(current_path).to eq(new_user_session_path)
    end
  end
end