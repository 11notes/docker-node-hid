'use strict';
const http = require('http');
const requestHandler = function(req, res){
    const HID = require('node-hid');
    const devices = HID.devices();
    res.end(JSON.stringify(devices, null, 2));
};
const server = http.createServer(requestHandler);
server.listen(8080, function(err){
    console.log('http server started.');
});