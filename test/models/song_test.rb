require "test_helper"

class SongTest < ActiveSupport::TestCase
  setup do
    @artist = Artist.create!(name: "Test Artist", bio: "Bio")
    @genre = Genre.create!(name: "Rock")
    @user = User.create!(username: "testsonguser", email: "songuser@example.com", password: "password123")
  end

  test "should not save song without title" do
    song = Song.new(artist: @artist, original_key: "G", content: "Letra de prueba de 10 caracteres")
    assert_not song.save, "Saved the song without a title"
  end

  test "should not save song without artist" do
    song = Song.new(title: "Test Song", original_key: "G", content: "Letra de prueba de 10 caracteres")
    assert_not song.save, "Saved the song without an artist"
  end

  test "should save valid song" do
    song = Song.new(title: "Test Song", artist: @artist, genre: @genre, user: @user, original_key: "Am", content: "Letra de prueba de 10 caracteres")
    assert song.save, "Could not save a valid song. Errors: #{song.errors.full_messages.join(', ')}"
  end

  test "search scope should find by song title" do
    Song.create!(title: "Unique Title ABC", artist: @artist, genre: @genre, user: @user, original_key: "C", content: "Letra de prueba de 10 caracteres")
    results = Song.search("Unique Title ABC")
    assert_equal 1, results.count
    assert_equal "Unique Title ABC", results.first.title
  end

  test "search scope should find by artist name" do
    Song.create!(title: "Some Song", artist: @artist, genre: @genre, user: @user, original_key: "C", content: "Letra de prueba de 10 caracteres")
    results = Song.search("Test Artist")
    assert results.count >= 1
  end
end
