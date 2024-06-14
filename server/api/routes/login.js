const express = require('express');
const router = express.Router();

const createDbConnection = require('../db/dbConnection');

router.post('/login', async (req, res) => {
  const { id, pwd } = req.query;
  try {
    const connection = await createDbConnection();
    const query = `SELECT id FROM user WHERE id = ? AND pwd = ?`;
    const [rows] = await connection.execute(query, [id, pwd]);
    await connection.end();

    if (rows.length > 0) {
      res.json({ success: true, message: 'Login successful' });
    } else {
      res.status(401).json({ success: false, message: 'Login failed: Invalid ID or password' });
    }
  } catch (error) {
    res.status(500).send('Error connecting to the database');
  }
});

module.exports = router;
