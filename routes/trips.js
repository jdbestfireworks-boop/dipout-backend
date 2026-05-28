const express = require('express');
const router = express.Router();
const controller = require('../controllers/tripsController');

router.get('/', controller.getTrips);

module.exports = router;
