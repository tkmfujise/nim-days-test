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


proc encode*(this: Encoder, obj: BencodeType): string

proc decode*(this: Decoder, source: string): (BencodeType, int)


# "foo" => "3:foo"
proc encode_s(this: Encoder, s: string): string =
  return $s.len & ":" & s


# 123 => "i123e"
proc encode_i(this: Encoder, i: int): string =
  return fmt("i{i}e")


# [I 123, S "foo"] => "li123e3:fooe"
proc encode_l(this: Encoder, l: seq[BencodeType]): string =
  result = "l"
  for el in l:
    result &= this.encode(el)
  result &= "e"


proc encode_d(this: Encoder, d: OrderedTable[BencodeType, BencodeType]): string =
  result = "d"
  for k, v in d.pairs():
    assert k.kind == btString
    result &= this.encode(k) & this.encode(v)
  result &= ""


proc encode*(this: Encoder, obj: BencodeType): string =
  case obj.kind
  of BencodeKind.btString: this.encode_s(obj.s)
  of BencodeKind.btInt:    this.encode_i(obj.i)
  of BencodeKind.btList:   this.encode_l(obj.l)
  of BencodeKind.btDict:   this.encode_d(obj.d)


# 3:foo => (S "foo", 1)
proc decode_s(this: Decoder, s: string): (BencodeType, int) =
  let prefixpart = s.split(":")[0]
  let prefixlen = prefixpart.len
  let bodylen = parseInt(prefixpart)
  let body = s[prefixlen+1..bodylen+1]
  let strlen = prefixlen + 1 + bodylen
  (BencodeType(kind: btString, s: body), strlen)


# i123e => (I 123, 5)
proc decode_i(this: Decoder, s: string): (BencodeType, int) =
  let epos = s.find('e')
  let i = parseInt(s[1..<epos])
  (BencodeType(kind: btInt, i: i), epos+1)


proc decode_l(this: Decoder, s: string): (BencodeType, int) =
  var els = newSeq[BencodeType]()
  var curchar = s[1]
  var idx = 1
  while idx < s.len:
    curchar = s[idx]
    if curchar == 'e':
      idx += 1
      break

    let pair = this.decode(s[idx..<s.len])
    let obj = pair[0]
    let nextObjPos = pair[1]
    els.add obj
    idx += nextObjPos

  return (BencodeType(kind: btList, l: els), idx)


proc decode_d(this: Decoder, s: string): (BencodeType, int) =
  var d = initOrderedTable[BencodeType, BencodeType]()
  var curchar = s[1]
  var idx = 1
  var readingKey = true
  var curKey: BencodeType
  while idx < s.len:
    curchar = s[idx]
    if curchar == 'e':
      break
    let pair = this.decode(s[idx..<s.len])
    let obj = pair[0]
    let nextObjPos = pair[1]
    if readingKey == true:
      curKey = obj
      readingKey = false
    else:
      d[curKey] = obj
      readingKey = true

    idx += nextObjPos

  return (BencodeType(kind: btDict, d: d), idx)


proc decode*(this: Decoder, source: string): (BencodeType, int) =
  var char = source[0]
  var idx = 0
  while idx < source.len:
    char = source[idx]
    let str = source[idx..<source.len]
    let pair = case char
      of 'i': this.decode_i(str)
      of 'l': this.decode_l(str)
      of 'd': this.decode_d(str)
      else:   this.decode_s(str)
    let obj = pair[0]
    idx += pair[1]
    return (obj, idx)

