require('remodal')
require('remodal/dist/remodal.css')
require('normalize.css/normalize.css')

const FastClick = require('fastclick');
FastClick.attach(document.body);

require('./chart')
require('./polling')
require('./dropdown')
