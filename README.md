browserstack-test
=================


## 準備
- `browserstack-conf.json` を自分のものに書き換える


## CircleCI内でE2Eテストを手動実行する
```
sh ./scripts/run-e2e-test-on-circle-ci.sh
```

- push 毎のCIテストでは、E2Eテストは実行されないようにしている
