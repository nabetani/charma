# frozen_string_literal: true

module Charma
  # Charma が raise する例外の基底クラス
  class Error < StandardError; end

  module Errors
    # ページサイズが不正
    class InvalidPageSize < Error; end

    # ページレイアウトが不正 ( :landscape でも :portrait でも nil でもない )
    class InvalidPageLayout < Error; end

    # オプションが不正 ( series が Array ではない、など )
    class InvalidOption < Error; end

    # ファイルタイプが不正 ( pdf でも svg でもない )
    class InvalidFileType < Error; end

    # 出力するものがない。ページがないとか、ページ内にチャートがないとか。
    class NothingToRender < Error; end

    # 発生するとしたらバグ、というエラー。
    class LogicError < Error; end
  end
end
