require "net/http"

# Busca tapas de discos en la API pública de Deezer (no pide clave) y las descarga
# para guardarlas con Active Storage.
class CoverFinder
  SEARCH_URL = "https://api.deezer.com/search/album".freeze
  # Solo se descargan imágenes de los servidores de Deezer
  IMAGE_HOST = /\A(e-)?cdns?-images\.dzcdn\.net\z/
  MAX_SIZE = 5.megabytes

  Result = Struct.new(:title, :artist, :image_url, :thumb_url, keyword_init: true)
  class Error < StandardError; end

  # Devuelve hasta 6 opciones. Primero busca exacto por artista y disco, y si no
  # encuentra nada, busca por texto libre.
  def self.search(artist:, title:)
    results = query(%(artist:"#{artist}" album:"#{title}"))
    results = query("#{artist} #{title}") if results.empty?
    # Primero los del mismo artista, y entre esos los que tienen el mismo título
    results.sort_by { |r| [ same?(r.artist, artist) ? 0 : 1, same?(r.title, title) ? 0 : 1 ] }
  end

  def self.same?(a, b)
    a.to_s.strip.casecmp?(b.to_s.strip)
  end

  def self.download(url)
    uri = URI.parse(url)
    raise Error, "La imagen no es de Deezer" unless uri.is_a?(URI::HTTPS) && uri.host.to_s.match?(IMAGE_HOST)

    response = get(uri)
    raise Error, "La imagen es muy pesada" if response.body.bytesize > MAX_SIZE

    StringIO.new(response.body)
  end

  def self.query(text)
    uri = URI(SEARCH_URL)
    uri.query = URI.encode_www_form(q: text, limit: 6)
    data = JSON.parse(get(uri).body)
    Array(data["data"]).map do |item|
      Result.new(
        title: item["title"],
        artist: item.dig("artist", "name"),
        image_url: item["cover_xl"],
        thumb_url: item["cover_medium"]
      )
    end
  rescue JSON::ParserError
    raise Error, "Deezer respondió algo que no se entiende"
  end

  def self.get(uri)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.get(uri.request_uri)
    end
    raise Error, "Deezer respondió con error #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response
  rescue SocketError, Timeout::Error, SystemCallError, OpenSSL::SSL::SSLError
    raise Error, "No se pudo conectar con Deezer. Revisá la conexión a internet."
  end

  private_class_method :query, :get, :same?
end
