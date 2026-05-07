module Tyst

using Base64

function obscure(answer::String; key="Tyst")
    bytes = transcode(UInt8, answer)
    keybytes = transcode(UInt8, repr(hash(key))[3:end])
    keystream = repeat(keybytes, ceil(Int, length(bytes) / length(keybytes)))[1:length(bytes)]
    obscured_bytes = xor.(bytes, keystream)
    return base64encode(obscured_bytes)
end

function reveal(scanned::String; key="Tyst")
    decoded = base64decode(scanned)
    keybytes = transcode(UInt8, repr(hash(key))[3:end])
    keystream = repeat(keybytes, ceil(Int, length(decoded) / length(keybytes)))[1:length(decoded)]
    revealed_bytes = xor.(decoded, keystream)
    return String(revealed_bytes)
end

export obscure, reveal

end
