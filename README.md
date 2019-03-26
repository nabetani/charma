# Charma

Create pages filled with charts in PDF format

適当にデータを突っ込んだらいい感じのグラフを作ってくれることを目指している。
出力は PDF のみ。

入力は `Hash`。CSV を読んだりする機能はない。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'charma'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install charma

## Usage

```ruby
require 'charma'

Charma::Document.new do |doc|
  doc.new_page do |page|
    page.add_barchart(
      series:[{y:[3,1,4,1,5]}],
      x_ticks:%w[ foo bar baz qux quux]
    )
  end
  doc.render( File.basename(__FILE__, ".*")+".pdf" )
end
```

Visit following pages:

* https://github.com/nabetani/charma/tree/master/examples
* https://github.com/nabetani/charma

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/charma. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Charma project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/charma/blob/master/CODE_OF_CONDUCT.md).

## Change logs

### v0.1.2

2019.3.25

* フォント指定を可能にした
* Violn chart で bins を指定可能にした

### v0.1.1

2019.3.24

* デバッグ用に描画していた枠を撤去した
* 利用例を追加した
* バイオリンチャートに外枠をつけた

### v0.1.0

2019.3.24

最初のリリース