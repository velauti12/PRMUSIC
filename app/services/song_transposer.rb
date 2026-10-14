class SongTransposer
  NOTES_SHARP = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
  NOTES_FLAT  = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

  # Regex para matchear acordes válidos
  CHORD_REGEX = /^[A-G][b#]?(?:m|min|maj|dim|aug)?(?:7|9|11|13)?(?:\/[A-G][b#]?)?$/

  def self.call(content, original_key, semitones)
    semitones = semitones.to_i % 12
    return content if semitones == 0 || content.blank?

    target_index = (note_index(original_key) + semitones) % 12
    use_flats = use_flats_for_index?(target_index, original_key.to_s)
    notes_array = use_flats ? NOTES_FLAT : NOTES_SHARP

    content.lines.map do |line|
      clean_line = line.rstrip
      if is_chord_line?(clean_line)
        transpose_chord_line(clean_line, semitones, notes_array) + "\n"
      else
        line
      end
    end.join
  end

  private

  def self.note_index(note)
    return 0 if note.blank?
    root = note.match(/^[A-G][b#]?/)[0] rescue "C"
    NOTES_SHARP.index(root) || NOTES_FLAT.index(root) || 0
  end

  def self.use_flats_for_index?(index, original_key)
    is_minor = original_key.include?("m")
    if is_minor
      # Escalas menores que suelen llevar bemoles: Cm, Dm, Fm, Gm, Bbm
      [0, 2, 5, 7, 10].include?(index)
    else
      # Escalas mayores que suelen llevar bemoles: F, Bb, Eb, Ab, Db
      [1, 3, 5, 8, 10].include?(index)
    end
  end

  def self.is_chord_line?(line)
    tokens = line.split(/\s+/)
    return false if tokens.empty?
    
    # La línea es de acordes si todos sus "palabras" son acordes válidos
    tokens.reject(&:empty?).all? { |token| token.match?(CHORD_REGEX) }
  end

  def self.transpose_chord_line(line, semitones, notes_array)
    # Reemplaza manteniendo los espacios exactos
    line.gsub(/[A-G][b#]?(?:m|min|maj|dim|aug)?(?:7|9|11|13)?(?:\/[A-G][b#]?)?/) do |chord_str|
      transpose_chord(chord_str, semitones, notes_array)
    end
  end

  def self.transpose_chord(chord, semitones, notes_array)
    match = chord.match(/^([A-G][b#]?)(.*)$/)
    return chord unless match

    root = match[1]
    mod = match[2]

    index = NOTES_SHARP.index(root) || NOTES_FLAT.index(root)
    return chord unless index

    new_index = (index + semitones) % 12
    new_root = notes_array[new_index]

    # Manejar acordes invertidos con bajo (ej: G/B)
    if mod.include?('/')
      slash_match = mod.match(/^(.*)\/([A-G][b#]?)$/)
      if slash_match
        bass_root = slash_match[2]
        bass_index = NOTES_SHARP.index(bass_root) || NOTES_FLAT.index(bass_root)
        if bass_index
          new_bass_index = (bass_index + semitones) % 12
          new_bass = notes_array[new_bass_index]
          return new_root + slash_match[1] + "/" + new_bass
        end
      end
    end

    new_root + mod
  end
end
