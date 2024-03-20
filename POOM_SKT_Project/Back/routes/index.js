const express = require('express');
const nugu = require('../nugu');
const router = express.Router();

router.post(`/nugu/Reading_Text`, nugu);
router.post(`/nugu/ProductNameAction`, (req, res, next) => {
    console.log(`[NUGU ProductNameAction Request] Input: ${JSON.stringify(req.body)}`);
    nugu(req, res, next);
  });
  router.post(`/nugu/Register_Data`, (req, res, next) => {
    console.log(`[NUGU ProductNameAction Request] Input: ${JSON.stringify(req.body)}`);
    nugu(req, res, next);
  });
  

module.exports = router;
