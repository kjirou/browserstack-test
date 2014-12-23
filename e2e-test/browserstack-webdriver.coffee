assert = require 'assert'
async = require 'async'
webdriver = require 'browserstack-webdriver'
test = require 'browserstack-webdriver/testing'

browserstackConf = require '../browserstack-conf.json'


#
# browserstack-webdriver の動作確認とサンプルとしてのテスト
#
# browserstack-webdriver は、selenium-webdriver をラッピングして、
# その中で mocha のラッパーを定義しているが、
# 元の selenium-webdriver や mocha で動くはずのコードが動かないことが多々ある。
#
# そのため、ここでは BrowserStack Automate の動作確認と共に、
# ハマらない、安定するテストの書き方を例示する。
#
test.describe 'browserstack-webdriver module', ->

  test.before ->

    capabilities =
      # ブラウザの設定
      browser: 'Chrome'
      browser_version: '38.0'
      os: 'OS X'
      os_version: 'Mavericks'
      'resolution': '1024x768'
      # 接続設定
      'browserstack.user': browserstackConf.username
      'browserstack.key': browserstackConf.access_key
      # Visual Logs に画像を表示する
      'browserstack.debug': 'true'

    @driver = new webdriver.Builder()
      .usingServer 'http://hub.browserstack.com/wd/hub'
      .withCapabilities capabilities
      .build()

  test.after ->
    # この quit は必ず最後に実行する
    # もし after を複数書く場合は、最後の after にすること
    @driver.quit()

  test.it 'example.comのtitleを検証する', ->
    # promise オブジェクトを return することで非同期処理の同期を行う仕組み
    # 以下でいうと driver.get() も .then() も promise を返す
    @driver.get 'http://example.com'
      .then => @driver.getTitle()
      .then (title) -> assert.strictEqual title, 'Example Domain'

  test.it '重いサイト代表でwww.adobe.comを検証する', ->
    @driver.get 'http://www.adobe.com/'
      .then => @driver.getTitle()
      .then (title) -> assert.strictEqual title, 'Adobe: Creative, marketing, and document management solutions'

  test.it 'example.com内のリンクを踏んで遷移した次のサイトのtitleを検証する', ->
    @driver.get 'http://example.com'
      .then =>
        # "More information..." リンクテキストからリンク要素を探す
        #
        # findElement のマニュアル)
        # http://selenium.googlecode.com/git/docs/api/javascript/class_webdriver_WebElement.html
        # By のマニュアル)
        # http://selenium.googlecode.com/git/docs/api/javascript/namespace_webdriver_By.html
        @driver.findElement webdriver.By.partialLinkText 'More'
      .then (linkElement) ->
        # クリックして遷移する
        linkElement.click()
      .then => @driver.getTitle()
      .then (title) ->
        # http://www.iana.org/domains/example (今は http://www.iana.org/domains/reserved へリダイレクト)
        # の title を検証する
        assert.strictEqual 'IANA — IANA-managed Reserved Domains', title

  test.it 'JSによるDOM操作を検査する代表でcoffeescript.orgを検証する', ->
    @driver.get 'http://coffeescript.org/'
      .then => @driver.getTitle()
      .then (title) -> assert.strictEqual 'CoffeeScript', title
      .then =>
        # "TRY COFFEESCRIPT" ボタンをクリックすると表示される "Run" ボタンを取得
        # By.css は CSS セレクタ記法で抽出できる、複雑な条件を指定したいなら一番便利
        @driver.findElement webdriver.By.css '.minibutton.dark.run'
      .then (runButton) -> runButton.isDisplayed()
      .then (isDisplayed) -> assert.strictEqual isDisplayed, false  # "Run" ボタンはまだ未表示
      .then => @driver.findElement webdriver.By.css '.navigation.try .button'
      .then (tryButton) -> tryButton.click()
      .then => @driver.findElement webdriver.By.css '.minibutton.dark.run'
      .then (runButton) -> runButton.isDisplayed()
      .then (isDisplayed) -> assert.strictEqual isDisplayed, true  # "Run" ボタンが表示された


  test.describe 'driver.get前にdeferredで同期を取る', ->

    test.it 'deferredで非同期処理の同期を行う場合は別のitにする必要がある', ->
      d = webdriver.promise.defer()
      setTimeout ->
        d.fulfill()
      , 500
      d.promise

    test.it 'should be', ->
      @driver.get 'http://example.com'
        .then => @driver.getTitle()
        .then (title) -> assert.strictEqual 'Example Domain', title
        #
        # 注意:
        # 以下のコードを挟むと、次の driver.getTitle() が返す promise が fulfill されない、
        # つまり、このテストが終了しなくなる。
        #
        # ========
        #.then ->
        #  d = webdriver.promise.defer()
        #  setTimeout ->
        #    d.fulfill()
        #  , 500
        #  d.promise
        # ========
        #
        # driver.get などが返す promise は別管理されてるらしいのが原因かもしれない（詳細未調査）、
        # mocha を外せば動くコードなので、多分 browserstack-webdriver のバグ。
        #
        # 上記の通り、別の it に分けて行えば実行可能なので、
        # データを非同期処理で前準備したい場合は、別の it で定義して変数を格納する。
        #
        # 根本的解決としては、テスティングフレームワークに mocha を使わないことだと思う。
        # そもそも、mocha の更新に追随する気が無いみたいなので。
        #
        .then => @driver.getTitle()


  test.describe 'promiseが進まなかったケース', ->

    test.it '非同期処理後にrejectしたらテスト終了時に止まったことがある', ->
      d = webdriver.promise.defer()
      async.series [
        (next) ->
          next new Error 'ERROR'
      ], (e) ->
        # ここで止まったことがあった、これだと動くなぁ..
        # エラーになると邪魔だから非エラーにしとく
        #return d.reject e if e
        d.fulfill()
      d.promise
