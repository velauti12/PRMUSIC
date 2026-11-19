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

  test "el álbum tiene que ser del mismo artista" do
    other = Artist.create!(name: "Otro artista")
    album = Album.create!(title: "Disco ajeno", artist: other)
    song = Song.new(title: "Tema", artist: @artist, album: album, original_key: "G", content: "Letra de prueba de 10 caracteres")
    assert_not song.valid?
    assert song.errors[:album].any?
  end

  test "limpia la letra pegada de una página web" do
    pegada = "​E        G#m\r\n​Solo la musica esta   \r\n"
    song = Song.create!(title: "Pegada", artist: @artist, genre: @genre, user: @user, original_key: "E", content: pegada)
    assert_equal "E        G#m\nSolo la musica esta\n", song.content
    assert_includes song.transposed_content(2), "F#        A#m"
  end

  test "saca el id del video de distintos links de YouTube" do
    [ "https://www.youtube.com/watch?v=dQw4w9WgXcQ", "https://youtu.be/dQw4w9WgXcQ?si=x",
      "https://www.youtube.com/watch?list=abc&v=dQw4w9WgXcQ", "https://youtube.com/shorts/dQw4w9WgXcQ" ].each do |url|
      assert_equal "dQw4w9WgXcQ", Song.new(video_url: url).youtube_id, url
    end
  end

  test "no acepta links que no son de YouTube" do
    song = Song.new(title: "Tema", artist: @artist, genre: @genre, original_key: "G",
                    content: "Letra de prueba de 10 caracteres", video_url: "https://vimeo.com/123")
    assert_not song.valid?
    assert song.errors[:video_url].any?
  end
end
