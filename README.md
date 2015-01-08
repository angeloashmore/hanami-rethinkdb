# Lotus::Model RethinkDB Adapter

This adapter implements a [Lotus::Model](https://github.com/lotus/model) persistence layer for [RethinkDB](http://rethinkdb.com).

## Status

[![Gem Version](https://badge.fury.io/rb/lotus-rethinkdb.svg)](http://badge.fury.io/rb/lotus-rethinkdb)
[![Build Status](https://secure.travis-ci.org/angeloashmore/lotus-rethinkdb.svg?branch=master)](http://travis-ci.org/angeloashmore/lotus-rethinkdb?branch=master)
[![Coverage Status](https://img.shields.io/coveralls/angeloashmore/lotus-rethinkdb.svg)](https://coveralls.io/r/angeloashmore/lotus-rethinkdb)
[![Code Climate](https://codeclimate.com/github/angeloashmore/lotus-rethinkdb/badges/gpa.svg)](https://codeclimate.com/github/angeloashmore/lotus-rethinkdb)
[![Inline docs](http://inch-ci.org/github/angeloashmore/lotus-rethinkdb.svg?branch=master&style=flat)](http://inch-ci.org/github/angeloashmore/lotus-rethinkdb)

## Links

* API Doc: [http://rdoc.info/gems/lotus-rethinkdb](http://rdoc.info/gems/lotus-rethinkdb)
* Bugs/Issues: [https://github.com/angeloashmore/lotus-rethinkdb/issues](https://github.com/angeloashmore/lotus-rethinkdb/issues)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lotus-rethinkdb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lotus-rethinkdb

## Usage

Please refer to the [Lotus::Model](https://github.com/lotus/model#usage) docs for any details related to Entity, Repository, Data Mapper and Adapter.

### Repository methods

See the [complete list](https://github.com/lotus/model#repositories) of Repository methods provided by ```Lotus::Model```.

Following methods are not supported since it's incompatible with RethinkDB:

* first
* last

### Query methods

Generic query methods supported by the RethinkDB adapter:

* [all](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#all-instance_method)
* [where](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#where-instance_method)
* [limit](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#limit-instance_method)
* [order](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#order-instance_method) (alias: ```asc```)
* [desc](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#desc-instance_method)
* [sum](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#dum-instance_method)
* [average](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#average-instance_method) (alias: ```avg```)
* [max](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#max-instance_method)
* [min](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#min-instance_method)
* [count](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#count-instance_method)

RethinkDB-specific methods:

* [pluck](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#pluck-instance_method)
* [has_fields](http://rubydoc.info/gems/lotus-rethinkdb/Lotus/Model/Adapters/Rethinkdb/Query#has_fields-instance_method)

## Contributing

1. Fork it ( https://github.com/angeloashmore/lotus-rethinkdb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
