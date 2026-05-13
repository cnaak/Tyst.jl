module Tyst

using Base64
using Printf

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
    DOCHDR = raw"""
    #import "@preview/based:0.2.0": base64

    #set page(
      paper: "a4",
      margin: (x: 20mm, top: 20mm, bottom: 25mm),
      numbering: none,
    )
    #set text(font: "IBM Plex Mono", size: 9.5pt, lang: "pt")
    #set par(justify: true, leading: .75em)

    #show math.equation: it => {
      text(font: "STIX Two Math", size: 0.90em)[#box[#it]]
    }

    """,
    QUEHDR = raw"""
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
    QUEIMG = raw"""
    #align(center)[
      #image("@IMAGEFILE@", width: @IMAGEWIDTH@)
    ]
    
    """,
    QUEASK = raw"""
    `[@WEIGHT@]`#h(.75em)@ASK@,#h(.75em)
    #box[$@VARNAME@ = $ #box(stroke: (bottom: 0.6pt), width: 6em) $@UNIT@$]

    """,
)

# document header generation
tydhdr() = PARTS.DOCHDR
export tydhdr

# question header generation
tyqhdr(obscured::String) = replace(PARTS.QUEHDR, "@OBSCURED@" => obscured)
export tyqhdr

# question image generation
function tyqimg(
        fil::String;
        wid::String = "45%",
    )
    return replace(
        PARTS.QUEIMG,
        "@IMAGEFILE@" => fil,
        "@IMAGEWIDTH@" => wid,
    )
end
export tyqimg

# question ask generation
function tyqask(
        ask::String;
        wgt::Integer = 1,
        var::String,
        uni::String,
    )
    return replace(
        PARTS.QUEASK,
        "@WEIGHT@" => @sprintf("%02d", wgt),
        "@ASK@" => ask,
        "@VARNAME@" => var,
        "@UNIT@" => uni,
    )
end
export tyqask

end
