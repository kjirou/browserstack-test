assert = require 'assert'
webdriver = require 'browserstack-webdriver'
test = require 'browserstack-webdriver/testing'
_ = require 'lodash'

browserstackConf = require '../browserstack-conf.json'


capabilities =
  resolution: '1024x768'
  'browserstack.user': browserstackConf.username
  'browserstack.key': browserstackConf.access_key
  'browserstack.local': 'true'
  'browserstack.debug': 'true'
  os: 'OS X',
  os_version:'Mavericks',
  browser: 'Chrome',
  browser_version: '38.0'


test.describe 'handle ajax test', ->

  test.describe 'Ajaxリクエストを送信した結果をテストできるか', ->

    test.before ->
      @driver = new webdriver.Builder()
        .usingServer 'http://hub.browserstack.com/wd/hub'
        .withCapabilities capabilities
        .build()

    test.after ->
      @driver.quit()

    test.it 'XMLHttpRequestで同期リクエストした結果がページに表示されている', ->
      @driver.get 'http://localhost:3000/do-ajax'
        .then => @driver.getPageSource()
        .then (source) =>
          console.log source
          assert /Ajax-Result/.test source
