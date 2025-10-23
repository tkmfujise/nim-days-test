import src/bencode

proc S*(s: string): BencodeType =
  BencodeType(kind: btString, s: s)

proc I*(i: int): BencodeType =
  BencodeType(kind: btInt, i: i)

proc L*(l: seq[BencodeType]): BencodeType =
  BencodeType(kind: btList, l: l)
