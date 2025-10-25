import unittest
import helper
import bencode, tables

suite "BencodeKind":
  test "works":
    check BencodeKind.btString == btString


suite "BencodeType":
  test "btString":
    let bts = BencodeType(kind: btString, s: "test")
    check bts.s == "test"

  test "btInt":
    let bti = BencodeType(kind: btInt, i: 42)
    check bti.i == 42

  test "bkList":
    let bts = BencodeType(kind: btString, s: "test")
    let bti = BencodeType(kind: btInt, i: 42)
    let btl = BencodeType(kind: btList, l: @[bts, bti])
    check btl.l == @[bts, bti]

  test "btDict":
    let bts = BencodeType(kind: btString, s: "test")
    let bti = BencodeType(kind: btInt, i: 42)
    let dict = { bts: bti }.toOrderedTable
    let btd = BencodeType(kind: btDict, d: dict)
    check btd.d == dict


suite "==":
  test "btString":
    let bts1 = BencodeType(kind: btString, s: "foo")
    let bts2 = BencodeType(kind: btString, s: "bar")
    let bts3 = BencodeType(kind: btString, s: "foo")
    check bts1 != bts2
    check bts1 == bts3

  test "btInt":
    let bti1 = BencodeType(kind: btInt, i: 42)
    let bti2 = BencodeType(kind: btInt, i: 24)
    let bti3 = BencodeType(kind: btInt, i: 42)
    check bti1 != bti2
    check bti1 == bti3

  test "bkList":
    let bts1 = BencodeType(kind: btString, s: "foo")
    let bts2 = BencodeType(kind: btString, s: "bar")
    let bts3 = BencodeType(kind: btString, s: "foo")
    let bti1 = BencodeType(kind: btInt, i: 42)
    let bti2 = BencodeType(kind: btInt, i: 24)
    let bti3 = BencodeType(kind: btInt, i: 42)
    let btl1 = BencodeType(kind: btList, l: @[bts1, bti1])
    let btl2 = BencodeType(kind: btList, l: @[bts2, bti2])
    let btl3 = BencodeType(kind: btList, l: @[bts3, bti3])
    let btl4 = BencodeType(kind: btList, l: @[bts3, bti2])
    check btl1 != btl2
    check btl1 == btl3
    check btl1 != btl4

  test "btDict":
    let bts1 = BencodeType(kind: btString, s: "foo")
    let bts2 = BencodeType(kind: btString, s: "bar")
    let bts3 = BencodeType(kind: btString, s: "foo")
    let bti1 = BencodeType(kind: btInt, i: 42)
    let bti2 = BencodeType(kind: btInt, i: 24)
    let bti3 = BencodeType(kind: btInt, i: 42)
    let btl1 = BencodeType(kind: btList, l: @[bts1, bti1])
    let btl2 = BencodeType(kind: btList, l: @[bts2, bti2])
    let btl3 = BencodeType(kind: btList, l: @[bts3, bti3])
    let btl4 = BencodeType(kind: btList, l: @[bts3, bti2])
    let btd1 = BencodeType(kind: btDict, d: { bts1: bti1 }.toOrderedTable)
    let btd2 = BencodeType(kind: btDict, d: { bts2: bti2 }.toOrderedTable)
    let btd3 = BencodeType(kind: btDict, d: { bts3: bti3 }.toOrderedTable)
    let btd4 = BencodeType(kind: btDict, d: { btl1: btl1 }.toOrderedTable)
    let btd5 = BencodeType(kind: btDict, d: { btl2: btl2 }.toOrderedTable)
    let btd6 = BencodeType(kind: btDict, d: { btl3: btl3 }.toOrderedTable)
    let btd7 = BencodeType(kind: btDict, d: { btl3: btl4 }.toOrderedTable)
    check btd1 != btd2
    check btd1 == btd3
    check btd1 != btd4
    check btd4 != btd5
    check btd4 != btd5
    check btd4 == btd6
    check btd4 != btd7


suite "encode":
  # See tests/helper.nim
  test "string":
    let encoder = Encoder.new
    check encoder.encode(S "Test") == "4:Test"
    check encoder.encode(S "a b c") == "5:a b c"
    check encoder.encode(S "あ") == "3:あ"

  test "int":
    let encoder = Encoder.new 
    check encoder.encode(I 123) == "i123e"
    check encoder.encode(I -12) == "i-12e"

  test "list":
    let encoder = Encoder.new
    check encoder.encode(L @[S("test")]) == "l4:teste"
    check encoder.encode(L @[I(123)]) == "li123ee"
    check encoder.encode(L @[S("F"), I(1)]) == "l1:Fi1ee"
    check encoder.encode(L @[I(123), S("foo")]) == "li123e3:fooe"

  test "dict":
    let encoder = Encoder.new
    check encoder.encode(D(S "foo", I 123)) == "d3:fooi123e"


suite "decode":
  test "string":
    let decoder = Decoder.new
    check decoder.decode_s("3:foo") == (S "foo", 5)
    check decoder.decode_s("27:ABCDEFGHIJKLMNOPQRSTUVWXYZ") == (S "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 30)

  test "int":
    let decoder = Decoder.new
    check decoder.decode_i("i123e") == (I 123, 5)

  test "list":
    let decoder = Decoder.new
    check decoder.decode_l("l4:teste") == (L @[S("test")], 8)
    check decoder.decode_l("li123ee") == (L @[I(123)], 7)
    check decoder.decode_l("l1:Fi1ee") == (L @[S("F"), I(1)], 8)
    check decoder.decode_l("li123e3:fooe") == (L @[I(123), S("foo")], 12)

  test "dict":
    let decoder = Decoder.new
    check decoder.decode_d("d3:fooi123e") == (D(S "foo", I 123), 11)

