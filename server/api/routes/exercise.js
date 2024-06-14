const express = require('express');
const router = express.Router();

const createDbConnection = require('../db/dbConnection');
//exercise

/* 
request body
{
  exercise_id : 00001
}

return json
{
  exercise_id : 00001,
  name : 'Bench Press',
  category : 'chest',
  description : 'Bench Press is a popular exercise for building chest muscles.'
}
*/

router.post('/get', async (req, res) => {
    const { exercise_id } = req.body;
  
    try {
      const connection = await createDbConnection();
      const query = 'SELECT exercise_id, name, category, description, target FROM exercise WHERE exercise_id = ?';
      const [rows] = await connection.execute(query, [exercise_id]);
      await connection.end();
  
      if (rows.length > 0) {
        res.json({
          exercise_id: rows[0].exercise_id,
          name: rows[0].name,
          category: rows[0].category,
          description: rows[0].description,
          target: rows[0].target
        });
      } else {
        res.status(404).json({ success: false, message: 'Exercise not found' });
      }
    } catch (error) {
      console.error('Database connection failed:', error);
      res.status(500).send('Error connecting to the database');
    }
  });
  

module.exports = router;