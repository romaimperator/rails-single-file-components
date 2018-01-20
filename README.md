# Rails::Sfc
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails-sfc'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rails-sfc
```

## Usage

To make a component, just put it in `app/components` with the extension `.sfc`. Here is a simple example:
```eruby
# app/components/my_component.sfc

<template>
  <h1>This is my component</h1>
  <p>Reasons to use single file components:</p>
  <ul>
    <li>keeps the CSS that effects a partial near the HTML that it is affecting</li>
    <li>helps prevent leftover unused CSS rules that weren't deleted when the HTML was deleted</li>
    <li>unlike inline styles or inline style blocks, they continue to keep the advantages of combining all styles into a single file</li>
    <li>allows CSS to be easily scoped to only the component</li>
  </ul>
</template>

<style>
h1 {
  font-size: 20px;
}

li {
  font-size: 15px;
}
</style>
```

When your component name conflicts with another partial, you can specify the format as `sfc` to make
select the component version but you must also use the long form like so:

```ruby
<%= render partial: 'my_component', locals: { my_local: my_value } %>
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
