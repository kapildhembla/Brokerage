var express = require('express');
var app = express();

var path = require('path');

app.use("/node_modules", express.static(__dirname + "/node_modules"));


// viewed at http://localhost:8080
app.get('/', function(req, res) {
    res.sendFile(path.join(__dirname + '/index.html'));
});
app.get('/broker', function(req, res) {
    res.sendFile(path.join(__dirname + '/Metamaskbroker.html'));
});


// start the server in the port 3000 !
app.listen(3000, function () {
    console.log('Example app listening on port 3000.');
});