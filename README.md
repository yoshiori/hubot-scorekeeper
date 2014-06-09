# scorekeeper  - hubot scripts *Beta*

```
Hubot> sora_h++
Hubot> sora_h increment!! (total : 1)
Hubot> hogelog++
Hubot> hogelog increment!! (total : 1)
Hubot> sora_h++
Hubot> sora_h increment!! (total : 2)
Hubot> yoshiori--
Hubot> yoshiori decrement!! (total : -1)
Hubot> hubot scorekeeper
Hubot> 1 : sora_h
Hubot> 2 : hogelog
Hubot> 3 : yoshiori
```

## Installation

Add `hubot-scorekeeper` to your `package.json` dependencies.

```json
"dependencies": {
  "hubot-scorekeeper": "0.0.1"
}
```

Run `npm install`

Add `hubot-scorekeeper` to `external-scripts.json`.



## Usage

* `#{something}++` - increment something
* `#{something}--` - decrement something
* `hubot scorekeeper` - show rank.
* `hubot scorekeeper #{something}` - show something's score

### mention's prefix

if you need ignore hipchat's mention.

```
export HUBOT_SCOREKEEPER_MENTION_PREFIX="@"
```

```
Hubot> @con_mame++
Hubot> con_mame increment!! (total : 1)
Hubot> con_mame++
Hubot> con_mame increment!! (total : 2)
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
