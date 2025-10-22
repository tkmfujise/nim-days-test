import strformat, tables, json, strutils, hashes


type
  BencodeKind* = enum
    btString, btInt, btList, btDict

  BencodeType* = ref object
    case kind*: BencodeKind
    of btString: s* : string
    of btInt: i*    : int
    of btList: l*   : seq[BencodeType]
    of btDict: d*   : OrderedTable[BencodeType, BencodeType]

  Encoder* = ref object
  Decoder* = ref object


