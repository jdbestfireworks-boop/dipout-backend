const express = require('express');
const router = express.Router();
const tripController = require('../controllers/tripController');

router.post('/create', tripController.createTrip);
router.post('/assign', tripController.assignDriver);
router.get('/:id', tripController.getTrip);

module.exports = router;
