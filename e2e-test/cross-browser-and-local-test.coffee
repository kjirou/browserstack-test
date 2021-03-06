assert = require 'assert'
webdriver = require 'browserstack-webdriver'
test = require 'browserstack-webdriver/testing'
_ = require 'lodash'

browserstackConf = require '../browserstack-conf.json'


defaultCapabilities =
  resolution: '1024x768'
  'browserstack.user': browserstackConf.username
  'browserstack.key': browserstackConf.access_key
  'browserstack.debug': 'true'

# テスト対象のブラウザリスト
# 各値は https://www.browserstack.com/automate/node#setting-os-and-browser で生成できる
browsers = [
  { os: 'Windows', os_version:'8.1', browser: 'IE', browser_version: '11.0' }
  #{ os: 'Windows', os_version:'8', browser: 'IE', browser_version: '10.0' }
  #{ os: 'Windows', os_version:'7', browser: 'IE', browser_version: '9.0' }
  { os: 'Windows', os_version:'7', browser: 'IE', browser_version: '8.0' }
  # Yosemite が良く失敗する！
  { os: 'OS X', os_version:'Yosemite', browser: 'Safari', browser_version: '8.0' }
  { os: 'OS X', os_version:'Mavericks', browser: 'Firefox', browser_version: '33.0' }
  { os: 'OS X', os_version:'Mavericks', browser: 'Chrome', browser_version: '38.0' }
  # たまに 10 秒以上掛かる
  #{ browserName: 'iPhone', platform: 'MAC', device: 'iPhone 5' }
  #{ browserName: 'android', platform: 'ANDROID', device: 'Samsung Galaxy S5' }
]

# タイトルを生成するヘルパー、てきとう
titleizeCapabilities = (capabilities) ->
  (for k in ['os', 'os_version', 'browser', 'browser_version', 'browserName', 'platform', 'device']
    if k of capabilities
      capabilities[k]
    else
      continue
  ).join '/'


test.describe 'cross-browser test sample', ->

  # ブラウザ別に describe と BrowserStack セッションを生成する
  for browserData in browsers then do (browserData) ->

    capabilities = _.extend {}, defaultCapabilities, browserData

    test.describe titleizeCapabilities(capabilities), ->

      test.before ->
        @driver = new webdriver.Builder()
          .usingServer 'http://hub.browserstack.com/wd/hub'
          .withCapabilities capabilities
          .build()

      test.after ->
        @driver.quit()

      test.it 'example.comのtitleを検証する', ->
        @driver.get 'http://example.com'
          .then => @driver.getTitle()
          .then (title) -> assert.strictEqual 'Example Domain', title


test.describe 'local test sample', ->

  for browserData in browsers then do (browserData) ->

    #
    # ローカルネットワークに対してテストを行うには、以下の設定が必要
    #
    # 1.事前に BrowserStackLocal プロセスの起動
    #   本プロジェクトでは、scripts/start-BrowserStackLocal.sh に設置
    # 2.'browserstack.local': 'true' を capabilities へ設定する
    #
    capabilities = _.extend {
      'browserstack.local': 'true'
    }, defaultCapabilities, browserData

    test.describe titleizeCapabilities(capabilities), ->

      test.before ->
        @driver = new webdriver.Builder()
          .usingServer 'http://hub.browserstack.com/wd/hub'
          .withCapabilities capabilities
          .build()

      test.after ->
        @driver.quit()

      test.it 'トップページを検証する', ->
        @driver.get 'http://localhost:3000'
          .then => @driver.getTitle()
          .then (title) -> assert.strictEqual 'Express', title
