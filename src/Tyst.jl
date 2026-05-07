module Tyst

using Base64

function obscure(answer::String; key = "Tyst")
    bytes = transcode(UInt8, answer)
    keybytes = transcode(UInt8, repr(hash(key))[3:end])
    keystream = repeat(keybytes, ceil(Int, length(bytes) / length(keybytes)))[1:length(bytes)]
    obscured_bytes = xor.(bytes, keystream)
    return base64encode(obscured_bytes)
end

function reveal(scanned::String; key = "Tyst")
    decoded = base64decode(scanned)
    keybytes = transcode(UInt8, repr(hash(key))[3:end])
    keystream = repeat(keybytes, ceil(Int, length(decoded) / length(keybytes)))[1:length(decoded)]
    revealed_bytes = xor.(decoded, keystream)
    return String(revealed_bytes)
end

export obscure, reveal

PARTS = (
    DOCHDR = """
	#import "@preview/based:0.2.0": base64

    #set page(
      paper: "a4",
      margin: (x: 20mm, top: 20mm, bottom: 25mm),
      numbering: "– 1 –"
    )
    #set text(font: "IBM Plex Mono", size: 9.5pt, lang: "pt")
    #set par(justify: true, leading: .75em)

    #show math.equation: it => {
      text(font: "STIX Two Math", size: 0.90em)[#box[#it]]
    }
    """,
    QUEHDR = """
    #import "@preview/zebra:0.1.0": qrcode

    #let the-qcode-raw = qrcode(width: 4.0em, "@OBSCURED@")

    #table(
      columns: (10%, 10%, 50%, 10%, 20%),
      align: (
        left + horizon,
        left + horizon,
        left + bottom,
        center + horizon,
        right + bottom
      ),
      stroke: none,
      table.cell(rowspan: 2)[#the-qcode-raw],
      [#box(height: 1.5em)[Nome:]], [#line(length: 100%, stroke: 0.6pt)],
      [Data:], [#line(length: 100%, stroke: 0.6pt)],
      [#box(height: 1.5em)[Ass.:]], [#line(length: 100%, stroke: 0.6pt)],
      [Nota:], [#line(length: 100%, stroke: 0.6pt)],
    )

    #set text(font: "Libertinus Sans", size: 11pt, lang: "pt")
    """,
    QUEIMG = """
    """,
	QUEASK = """
    `[@WEIGHT@]`#h(.5em)@ASK@,
    #box[$@VARNAME@ = $ #box(stroke: (bottom: 0.6pt), width: 6em) $@UNIT@$]
	""",
)



end
