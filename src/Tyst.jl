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
    #let ANSKEY = @ANSKEY@
    #let ANS(body, wid: 8em, hei: 0.7em) = box(
        stroke: (bottom: 0.4pt + luma(128)),
        width: wid,
        height: hei,
    )[#align(center)[
        #text(
            font: "Crimson Pro",
            size: 0.83em,
            fill: red.darken(25%),
        )[#if ANSKEY [#body] else [#hide[#body]]]
    ]]
    // This determines whether or not answers will be displayed
    """,
    QHDRQR = raw"""
    """,
    QUEIMG = raw"""
    #align(center)[
      #image("@IMAGEFILE@", width: @IMAGEWIDTH@)
    ]
    """,
    QUEASK = raw"""
    `[@WEIGHT@]`#h(.75em)@ASK@,#h(.75em)
    #box[$@VARNAME@ = $ #ANS()[@ANSWER@] $@UNIT@$]
    """,
)

# document header generation
tydhdr(; anskey::Bool = false) = replace(
    PARTS.DOCHDR,
    "@ANSKEY@" => anskey ? "true" : "false",
)
export tydhdr

# question header template generation
function QUEHDR(QR::Bool)
    ret = QR ? raw"""
    #import "@preview/zebra:0.1.0": qrcode
    #let the-qcode-raw = qrcode(width: @QRWIDTH@em, "@OBSCURED@")
    """ : ""
    ret *= QR ? raw"""
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
    """ : raw"""
    #table(
        columns: (1fr, 7fr, 1fr, 2fr),
        align: (
            left + bottom,
            left + bottom,
            center + bottom,
            right + bottom
        ),
        stroke: none,
        inset: 0pt,
    """
    ret *= raw"""
        table.cell(colspan: 4)[#box(height: 0.8em)[
            @BANNER@
        ]],
        [#box(height: @HEIGHT@em)[Nome:]], [#line(length: 100%, stroke: 0.6pt)],
        [Data:], [#line(length: 100%, stroke: 0.6pt)],
        [Ass.:], [#line(length: 100%, stroke: 0.6pt)],
        [Nota:], [#line(length: 100%, stroke: 0.6pt)],
    )
    #set text(font: "Libertinus Sans", size: 11pt, lang: "pt")
    """
    return ret
end

# question header generation
tyqhdr(obscured::String="ha-ha!";
    banner::Vector{String},
    QR::Bool=true,
    wid::Float64=4.5,
) = replace(
    QUEHDR(QR),
    "@OBSCURED@" => obscured,
    "@QRWIDTH@" => @sprintf("%.2f", wid),
    "@QRWIDTHTAB@" => @sprintf("%.2f", wid + 0.8),
    "@HEIGHT@" => @sprintf("%.2f", (wid - 0.8) / 2),
    "@BANNER@" => join(banner, "\n        #box(width: 1fr)[#align(center)[---]]\n        "),
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
        var::String,
        uni::String,
        ans::String,
        wgt::Integer = 1,
    )
    return replace(
        PARTS.QUEASK,
        "@WEIGHT@" => @sprintf("%02d", wgt),
        "@ASK@" => ask,
        "@VARNAME@" => var,
        "@UNIT@" => uni,
        "@ANSWER@" => ans,
    )
end
export tyqask

end
