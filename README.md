# Hanami::Model RethinkDB Adapter

This adapter implements a [Hanami::Model](https://github.com/hanami/model) persistence layer for [RethinkDB](http://rethinkdb.com).

## Status

[![Gem Version](https://badge.fury.io/rb/hanami-rethinkdb.svg)](http://badge.fury.io/rb/hanami-rethinkdb)
[![Build Status](https://secure.travis-ci.org/angeloashmore/hanami-rethinkdb.svg?branch=master)](http://travis-ci.org/angeloashmore/hanami-rethinkdb?branch=master)
[![Coverage Status](https://img.shields.io/coveralls/angeloashmore/hanami-rethinkdb.svg)](https://coveralls.io/r/angeloashmore/hanami-rethinkdb)
[![Code Climate](https://codeclimate.com/github/angeloashmore/hanami-rethinkdb/badges/gpa.svg)](https://codeclimate.com/github/angeloashmore/hanami-rethinkdb)
[![Inline docs](http://inch-ci.org/github/angeloashmore/hanami-rethinkdb.svg?branch=master&style=flat)](http://inch-ci.org/github/angeloashmore/hanami-rethinkdb)

## Links

* API Doc: [http://rdoc.info/gems/hanami-rethinkdb](http://rdoc.info/gems/hanami-rethinkdb)
* Bugs/Issues: [https://github.com/angeloashmore/hanami-rethinkdb/issues](https://github.com/angeloashmore/hanami-rethinkdb/issues)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hanami-rethinkdb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hanami-rethinkdb

## Usage

Please refer to the [Hanami::Model](https://github.com/hanami/model#usage) docs for any details related to Entity, Repository, Data Mapper and Adapter.

### Repository methods

See the [complete list](https://github.com/hanami/model#repositories) of Repository methods provided by ```Hanami::Model```.

Following methods are not supported since it's incompatible with RethinkDB:

* first
* last

### Query methods

Generic query methods supported by the RethinkDB adapter:

* [all](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#all-instance_method)
* [where](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#where-instance_method)
* [limit](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#limit-instance_method)
* [order](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#order-instance_method) (alias: ```asc```)
* [desc](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#desc-instance_method)
* [sum](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#dum-instance_method)
* [average](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#average-instance_method) (alias: ```avg```)
* [max](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#max-instance_method)
* [min](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#min-instance_method)
* [count](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#count-instance_method)

RethinkDB-specific methods:

* [pluck](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#pluck-instance_method)
* [has_fields](http://rubydoc.info/gems/hanami-rethinkdb/Hanami/Model/Adapters/Rethinkdb/Query#has_fields-instance_method)

## Contributing

1. Fork it ( https://github.com/angeloashmore/hanami-rethinkdb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
