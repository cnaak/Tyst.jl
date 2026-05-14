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
            margin: (x: 20mm, top: 20mm, bottom: 20mm),
            numbering: none,
        )
        #set text(font: "IBM Plex Mono", size: 9.5pt, lang: "pt")
        #set par(justify: true, leading: .70em)
        #show math.equation: it => {
            text(font: "STIX Two Math", size: 0.90em)[#box[#it]]
        }
    """,
    QUEHDR = raw"""
    #import "@preview/zebra:0.1.0": qrcode
    #let the-qcode-raw = qrcode(width: @QRWIDTH@em, "@OBSCURED@")
    #table(
        columns: (@QRWIDTHTAB@em, 1fr, 7fr, 1fr, 2fr),
        align: (
            left + bottom,
            left + bottom,
            left + bottom,
            center + bottom,
            right + bottom
        ),
        stroke: none,
        inset: 0pt,
        table.cell(rowspan: 3)[#the-qcode-raw],
        table.cell(colspan: 4)[
            #box(height: @THIRDHEIGHT@em)[
            UTFPR-GP
            #box(width: 1fr)[#align(center)[---]]
            COEME
            #box(width: 1fr)[#align(center)[---]]
            M04
            #box(width: 1fr)[#align(center)[---]]
            EM48C
            #box(width: 1fr)[#align(center)[---]]
            Geração e Distribuição de Vapor
            ]
        ],
        [#box(height: @THIRDHEIGHT@em)[Nome:]], [#line(length: 100%, stroke: 0.6pt)],
        [Data:], [#line(length: 100%, stroke: 0.6pt)],
        [Ass.:], [#line(length: 100%, stroke: 0.6pt)],
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
tyqhdr(obscured::String, ems::Float64=7.5) = replace(
    PARTS.QUEHDR,
    "@OBSCURED@" => obscured,
    "@QRWIDTH@" => @sprintf("%.2f", ems),
    "@QRWIDTHTAB@" => @sprintf("%.2f", ems + 0.5),
    "@THIRDHEIGHT@" => @sprintf("%.2f", ems/3),
)
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
