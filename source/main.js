'use strict';
const HID = require('node-hid');
const devices = HID.devices();
console.log(devices);