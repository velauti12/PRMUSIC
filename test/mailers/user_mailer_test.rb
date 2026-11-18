require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome_email" do
    user = users(:one)
    mail = UserMailer.with(user: user).welcome_email
    assert_equal "¡Bienvenido a PRMUSIC!", mail.subject
    assert_equal [ user.email ], mail.to
    assert_equal [ "no-reply@prmusic.com" ], mail.from
    assert_match user.username, mail.body.encoded
  end
end
