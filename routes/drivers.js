const express = require('express');
const router = express.Router();
const controller = require('../controllers/driversController');

router.get('/', controller.getDrivers);

module.exports = router;
