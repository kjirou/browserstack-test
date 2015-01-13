var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'Express' });
});

router.get('/do-ajax', function(req, res) {
  res.render('do-ajax');
});

router.all('/text', function(req, res) {
  res.send('Ajax-Result');
});

module.exports = router;
