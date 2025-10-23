import src/bencode, tables

proc S*(s: string): BencodeType =
  BencodeType(kind: btString, s: s)

proc I*(i: int): BencodeType =
  BencodeType(kind: btInt, i: i)

proc L*(l: seq[BencodeType]): BencodeType =
  BencodeType(kind: btList, l: l)

proc D*(k: BencodeType, v: BencodeType): BencodeType =
  BencodeType(kind: btDict, d: { k: v }.toOrderedTable)
