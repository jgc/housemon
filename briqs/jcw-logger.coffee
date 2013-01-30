exports.info =
  name: 'jcw-logger'
  description: 'Log incoming data to rotating text files'

state = require '../server/state'
fs = require 'fs'

LOGGER_PATH = './logger'
fs.mkdir LOGGER_PATH

dateFilename = (now) ->
  # construct the date value as 8 digits
  d = now.getUTCDate() + 100 * (now.getUTCMonth() + 100 * now.getUTCFullYear())
  # then massage it as a string to produce a file name
  "#{LOGGER_PATH}/#{d}.txt"

timeString = (now) ->
  # first construct the value as 10 digits
  digits = now.getUTCMilliseconds() + 1000 *
          (now.getUTCSeconds() + 100 *
          (now.getUTCMinutes() + 100 *
          (now.getUTCHours() + 100)))
  # then massage it as a string to get the punctuation right
  digits.toString().replace /.(..)(..)(..)(...)/, '$1:$2:$3.$4'

exports.factory = class
  
  logger: (type, device, data) ->
    now = new Date
    name = dateFilename(now)
    if name isnt @currName
      @fd?.close()
      @currName = name
      @fd = fs.createWriteStream name
    # L 01:02:03.537 usb-A40117UK OK 9 25 54 66 235 61 13 183 235 210 226 33 19
    @fd.write "L #{timeString now} #{device} #{data}\n"

  constructor: ->
    @fd = null
    state.on 'incoming', @logger
          
  destroy: ->
    state.off 'incoming', @logger
    @fd?.close()
