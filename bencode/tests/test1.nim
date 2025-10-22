import unittest
import bencode

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
    # let dict = { bts: bti }.toOrderedTable
    # let btd = BencodeType(kind: btDict, d: dict)


suite "Encoder":
  test "works":
    let encoder = Encoder.new

