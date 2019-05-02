# frozen_string_literal: true

module Charma
  # デフォルトの紙
  DEFAULT_PAGE_SIZE = "A4"

  # 紙の名前と大きさの対照表。実部が横幅。虚部が縦幅。
  # TODO: Bサイズや LETTER, LEGAL などをいれる
  PAPER_SIZES = {
    A0:841.0+1189.0i,
    A1:594.0+841.0i,
    A2:420.0+594.0i,
    A3:297.0+420.0i,
    A4:210.0+297.0i,
    A5:148.0+210.0i,
    A6:105.0+148.0i,
    A7:74.0+105.0i,
    A8:52.0+74.0i,
    A9:37.0+52.0i,
    A10:26.0+37.0i
  }
end
