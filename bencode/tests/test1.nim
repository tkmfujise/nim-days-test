import unittest
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


suite "Encoder":
  test "works":
    let encoder = Encoder.new

