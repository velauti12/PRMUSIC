module AdminHelper
  STATUS_LABELS = { "pending" => "Pendiente", "approved" => "Aprobada", "rejected" => "Rechazada" }.freeze
  CHORD = /\A[A-G][b#]?(?:m|min|maj|dim|aug)?(?:7|9|11|13)?(?:\/[A-G][b#]?)?\z/

  def status_label(status)
    STATUS_LABELS.fetch(status.to_s, status.to_s)
  end

  def status_plural(status)
    { "pending" => "Pendientes", "approved" => "Aprobadas", "rejected" => "Rechazadas" }.fetch(status.to_s)
  end

  def status_tag(song)
    tag.span(status_label(song.status), class: "status status-#{song.status}")
  end

  def status_options
    Song.statuses.keys.map { |s| [ status_label(s), s ] }
  end

  # Botón de borrar con confirmación del navegador (no usamos Turbo)
  def delete_button(path, confirm:, label: "Borrar", css: "btn-link danger")
    button_to label, path, method: :delete, class: css,
                           form: { onsubmit: "return confirm(#{confirm.to_json})" }
  end

  # Link al sitio público (el front en React)
  def front_url
    ENV.fetch("FRONTEND_URL", "http://localhost:5173").split(",").first.strip
  end

  # Muestra la cifra marcando en rojo las líneas que son solo acordes
  def chord_sheet(content)
    lines = content.to_s.split("\n", -1).map do |line|
      tokens = line.split
      chords = tokens.any? && tokens.all? { |t| t.match?(CHORD) }
      chords ? tag.span(line, class: "chord-line") : ERB::Util.html_escape(line)
    end
    tag.pre(safe_join(lines, "\n"), class: "sheet", id: "sheet")
  end
end
