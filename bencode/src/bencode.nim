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


proc `$`*(a: BencodeType): string =
  case a.kind
  of btString: fmt("<Bencode {a.s}>")
  of btInt:    fmt("<Bencode {a.i}>")
  of btList:   fmt("<Bencode {a.l}>")
  of btDict:   fmt("<Bencode {a.d}>")


proc hash*(obj: BencodeType): Hash =
  case obj.kind
  of btString: !$(hash(obj.s))
  of btInt:    !$(hash(obj.i))
  of btList:   !$(hash(obj.l))
  of btDict:
    var h = 0
    for k, v in obj.d.pairs:
      h = h !& hash(k) !& hash(v)
    !$(h)


func `==`*(a, b: BencodeType): bool =
  if a.isNil:
    return b.isNil
  elif b.isNil or a.kind != b.kind:
    return false
  else:
    case a.kind
    of btString: return a.s == b.s
    of btInt:    return a.i == b.i
    of btList:
      if a.l.len != b.l.len: return false
      for i in 0..<a.l.len:
        if a.l[i] != b.l[i]: return false
      return true
    of btDict:
      if a.d.len != b.d.len: return false
      for key, val in a.d:
        var found = false
        for k, v in b.d:
          if k == key and v == val:
            found = true
            break
        if not found: return false
      result = true


