require 'rails_helper'

RSpec.describe "Tweets", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @tweet_text = Faker::Lorem.sentence
    @tweet_image = Faker::Lorem.sentence
  end

  context "success in tweet" do
    it "ログインしたユーザーは新規投稿できる" do
      sign_in(@user)
      expect(page).to have_content("投稿する")
      visit new_tweet_path
      fill_in "tweet_image", with: @tweet_image
      fill_in "tweet_text", with: @tweet_text
      expect{
        find('input[name="commit"]').click
      }.to change { Tweet.count }.by(1)
      expect(page).to have_content("投稿が完了しました。")
      visit root_path
      expect(page).to have_selector ".content_post[style='background-image: url(#{@tweet_image});']"
      expect(page).to have_content(@tweet_text)
    end
  end

  context "failer in tweet" do
    it "ログインしていないと新規投稿ページに遷移できない" do
      visit root_path
      expect(page).to have_no_content("投稿する")
    end
  end
end

RSpec.describe "edit tweet", type: :system do
  before do
    @tweet1 = FactoryBot.create(:tweet)
    @tweet2 = FactoryBot.create(:tweet)
  end
  context "success in edit of tweet" do
    it "ログインしたユーザーは自分が投稿したツイートの編集ができる" do
      sign_in(@tweet1.user)
      expect(
        all(".more")[1].hover
      ).to have_link "編集", href: edit_tweet_path(@tweet1)
      visit edit_tweet_path(@tweet1)
      expect(
        find("#tweet_image").value
      ).to eq(@tweet1.image)
      expect(
        find("#tweet_text").value
      ).to eq(@tweet1.text)
      fill_in "tweet_image", with: "#{@tweet1.image}+編集した画像URL"
      fill_in "tweet_text", with: "#{@tweet1.text}+編集したテキスト"
      expect{
        find('input[name="commit"]').click
      }.to change { Tweet.count }.by(0)
      expect(current_path).to eq(tweet_path(@tweet1))
      expect(page).to have_content("更新が完了しました。")
      visit root_path
      expect(page).to have_selector ".content_post[style='background-image: url(#{@tweet1.image}+編集した画像URL);']"
      expect(page).to have_content("#{@tweet1.text}+編集したテキスト")
    end
  end
  context "Failer in editting tweet" do
    it "ログインしたユーザーは自分以外が投稿したツイートの編集画面には遷移できない" do
      sign_in(@tweet1.user)
      expect(
        all(".more")[0].hover
      ).to have_no_link "編集", href: edit_tweet_path(@tweet2)
    end
    it "ログインしていないとツイートの編集画面には遷移できない" do
      visit root_path
      expect(
        all(".more")[1].hover
      ).to have_no_link "編集", href: edit_tweet_path(@tweet1)
      expect(
        all(".more")[0].hover
      ).to have_no_link "編集", href: edit_tweet_path(@tweet2)
    end
  end
end

RSpec.describe "delete tweet", type: :system do
  before do
    @tweet1 = FactoryBot.create(:tweet)
    @tweet2 = FactoryBot.create(:tweet)
  end

  context "success in deleting tweet" do
    it "ログインしたユーザーは自分の投稿したツイートが削除できる" do
      sign_in(@tweet1.user)
      expect(
        all(".more")[1].hover
      ).to have_link "削除", href: tweet_path(@tweet1)
      expect{
        all(".more")[1].hover.find_link("削除", href: tweet_path(@tweet1)).click
      }.to change { Tweet.count }.by(-1)
      expect(current_path).to eq(tweet_path(@tweet1))
      expect(page).to have_content("削除が完了しました。")
      visit root_path
      expect(page).to have_no_selector ".content_post[style='background-image: url(#{@tweet1.image});']"
      expect(page).to have_no_content("#{@tweet1.text}")
    end

  end

  context "failer in deleting tweet" do
    it "ログインしたユーザーは自分以外が投稿したツイートの削除ができない" do
      sign_in(@tweet1.user)
      expect(
        all(".more")[0].hover
      ).to have_no_link "削除", href: tweet_path(@tweet2)
    end
    it "ログインしていないとツイートの削除ボタンがない" do
      visit root_path
      expect(
        all(".more")[1].hover
      ).to have_no_link "削除", href: tweet_path(@tweet1)
      expect(
        all(".more")[0].hover
      ).to have_no_link "削除", href: tweet_path(@tweet2)
    end
  end
end

RSpec.describe "detail of tweet", type: :system do
  before do
    @tweet = FactoryBot.create(:tweet)
  end

  it "ログインしたユーザーはツイート詳細ページに遷移したコメント投稿欄が表示される" do
    # ログインする
    sign_in(@tweet.user)
    # ツイートに「詳細」へのリンクがあることを確認する
    expect(
      all(".more")[0].hover
    ).to have_link "詳細", href: tweet_path(@tweet)
    # 詳細ページに遷移する
    visit tweet_path(@tweet)
    # 詳細ページにツイートの内容が含まれている
    expect(page).to have_selector ".content_post[style='background-image: url(#{@tweet.image});']"
    expect(page).to have_content("#{@tweet.text}")
    # コメント用のフォームが存在する
    expect(page).to have_selector "form"
  end
  
  it "ログインしていない状態でツイート詳細ページに遷移できるもののコメント投稿欄が表示されない" do
    # トップページに移動する
    visit root_path
    # ツイートに「詳細」へのリンクがあることを確認する
    expect(
      all(".more")[0].hover
    ).to have_link "詳細", href: tweet_path(@tweet)
    # 詳細ページに遷移する
    visit tweet_path(@tweet)
    # 詳細ページにツイートの内容が含まれている
    expect(page).to have_selector ".content_post[style='background-image: url(#{@tweet.image});']"
    expect(page).to have_content("#{@tweet.text}")
    # フォームが存在しないことを確認する
    expect(page).to have_no_selector "form"
    # 「コメントの投稿には新規登録/ログインが必要です」が表示されていることを確認する
    expect(page).to have_content "コメントの投稿には新規登録/ログインが必要です"
  end
end