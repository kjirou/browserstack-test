#!/bin/sh

#
# BrowserStack Automate を使った E2E テストコードを実行するための環境を作る
#
# E2E テストを実行する環境で、これを実行すると(概ね)環境が整うようにする
# とりあえずは、開発用 Mac と CircleCI に対応
#
# $SELENIUM 環境変数だけ設定できていないので、別途設定する必要がある
# ここでは、Mac は direnv で、CircleCI は circle.yml で設定している
#


#
# 設定値
#

SELENIUM_SERVER_STANDALONE_FILENAME='selenium-server-standalone-2.44.0.jar'
SELENIUM_SERVER_STANDALONE_URL='http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar'

BROWSERSTACK_LOCAL_ZIP_MAC_FILENAME='BrowserStackLocal-darwin-x64.zip'
BROWSERSTACK_LOCAL_ZIP_MAC_URL='https://www.browserstack.com/browserstack-local/'$BROWSERSTACK_LOCAL_ZIP_MAC_FILENAME
BROWSERSTACK_LOCAL_ZIP_LINUX_X64_FILENAME='BrowserStackLocal-linux-x64.zip'
BROWSERSTACK_LOCAL_ZIP_LINUX_X64_URL='https://www.browserstack.com/browserstack-local/'$BROWSERSTACK_LOCAL_ZIP_LINUX_X64_FILENAME

SCRIPT_ROOT=$(cd $(dirname $0) && pwd)
ROOT=$SCRIPT_ROOT/..
BIN_ROOT=$ROOT/bin


#
# Selenium Server の設定
#

# bin/selenium-server-standalone-x.x.x.jar が無ければ DL する
SELENIUM_SERVER_STANDALONE_PATH=$BIN_ROOT/$SELENIUM_SERVER_STANDALONE_FILENAME
if [ ! -f $SELENIUM_SERVER_STANDALONE_PATH ]; then
  wget -O $SELENIUM_SERVER_STANDALONE_PATH $SELENIUM_SERVER_STANDALONE_URL
fi

# $SELENIUM 環境変数を要求する
if  [ "$SELENIUM" = '' ]; then
  echo '$SELENIUM 環境変数が未定義です'
  exit 1
elif [ "$SELENIUM" != '' -a ! -f $SELENIUM ]; then
  echo '$SELENIUM 環境変数が誤っています'
  exit 1
fi


#
# BrowserStackLocal の設定
#
BROWSERSTACK_LOCAL_FILENAME=BrowserStackLocal
BROWSERSTACK_LOCAL_PATH=$BIN_ROOT/$BROWSERSTACK_LOCAL_FILENAME
if [ ! -f $BROWSERSTACK_LOCAL_PATH ]; then
  if [ `uname` = 'Darwin' ]; then
    BROWSERSTACK_LOCAL_ZIP_PATH=$BIN_ROOT/$BROWSERSTACK_LOCAL_ZIP_MAC_FILENAME
    wget -O $BROWSERSTACK_LOCAL_ZIP_PATH --no-check-certificate $BROWSERSTACK_LOCAL_ZIP_MAC_URL
  else
    BROWSERSTACK_LOCAL_ZIP_PATH=$BIN_ROOT/$BROWSERSTACK_LOCAL_ZIP_LINUX_X64_FILENAME
    wget -O $BROWSERSTACK_LOCAL_ZIP_PATH --no-check-certificate $BROWSERSTACK_LOCAL_ZIP_LINUX_X64_URL
  fi
  unzip $BROWSERSTACK_LOCAL_ZIP_PATH -d $BIN_ROOT
  rm $BROWSERSTACK_LOCAL_ZIP_PATH
fi
