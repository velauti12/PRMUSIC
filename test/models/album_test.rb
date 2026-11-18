require "test_helper"

class AlbumTest < ActiveSupport::TestCase
  test "requiere título" do
    album = Album.new(artist: artists(:one))
    assert_not album.valid?
    assert album.errors[:title].any?
  end

  test "acepta una portada PNG" do
    album = albums(:one)
    album.cover.attach(io: file_fixture("cover.png").open, filename: "cover.png", content_type: "image/png")
    assert album.valid?
  end

  test "rechaza una portada que no es imagen" do
    album = albums(:one)
    album.cover.attach(io: file_fixture("not_an_image.txt").open, filename: "x.txt", content_type: "text/plain")
    assert_not album.valid?
    assert_includes album.errors[:cover].join, "imagen"
  end
end
