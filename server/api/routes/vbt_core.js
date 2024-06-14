const express = require('express');
const router = express.Router();

const createDbConnection = require('../db/dbConnection');


/* 
request body
{
  exercise_id : 00001
  user_id : 00232
}
return json
{
  data : []
}
*/

async function saveTestByWorkout(user_id, test_regression_id) {
  let status = 'ready'
  let routine_id = null
  let workout_regression_id = null
  try {
    const connection = await createDbConnection();
    const insertQuery = `
      INSERT INTO workout 
        (user_id, routine_id, test_regression_id, workout_regression_id, status, date)
      VALUES
        (?, ?, ?, ?, ?, CURDATE());
    `;

    const [result] = await connection.execute(insertQuery, [
      user_id,
      routine_id,
      test_regression_id,
      workout_regression_id,
      status
    ]);
    await connection.end();

    return true
  } catch (error) {
    console.error('Database connection failed:', error);
    return false
  }
}

router.post('/getAll', async (req, res) => {
  const { exercise_id, user_id } = req.body;

  try {
    const connection = await createDbConnection();
    const query = `
      SELECT regression_id, exercise_id, exercise_name, slope, y_intercept, r_squared, creation_date, type, one_rep_max
      FROM regression_results
      WHERE exercise_id = ? AND user_id = ?
      ORDER BY regression_id DESC;`; // Changed the sorting to regression_id in ascending order

    const [rows] = await connection.execute(query, [exercise_id, user_id]);
    await connection.end();

    res.json({
      data: rows
    });
  } catch (error) {
    console.error('Database connection failed:', error);
    res.status(500).send('Error connecting to the database');
  }
});


/* 
request body
{
  exercise_id : 00001
  user_id : 00232
  regression_id : 00001
}

return json
{
  data : {
    date : '2024.05.01', 
    r_squared : '',
    slope : '', 
    y_intercept : ''
  }
}
*/

router.post('/get', async (req, res) => {
  const { exercise_id, user_id, regression_id } = req.body;

  try {
    const connection = await createDbConnection();
    const query = `
      SELECT creation_date AS date, r_squared, slope, y_intercept, type, one_rep_max
      FROM regression_results
      WHERE exercise_id = ? AND user_id = ? AND regression_id = ?`;

    const [rows] = await connection.execute(query, [exercise_id, user_id, regression_id]);
    await connection.end();

    if (rows.length > 0) {
      res.json({
        data: rows[0]
      });
    } else {
      res.status(404).json({ message: 'No data found' });
    }
  } catch (error) {
    console.error('Database connection failed:', error);
    res.status(500).send('Error connecting to the database');
  }
});


/*
request body
{
  user_id: 00232,
  exercise_id: 00001,
  name: 'Bench Press',
  regression: {
    r_squared: 0.9,
    slope: 0.1,
    y_intercept: 0.2
    type : 'Test'
    one_rep_max : 100
  }
}

response json
{
  regression_id: 00001
}
*/

router.post('/save', async (req, res) => {
  const { user_id, exercise_id, name, regression } = req.body;
  const { r_squared, slope, y_intercept, type, one_rep_max } = regression;

  try {
    const connection = await createDbConnection();
    const insertQuery = `
      INSERT INTO regression_results 
        (user_id, exercise_id, exercise_name, slope, y_intercept, r_squared, type, one_rep_max, creation_date)
      VALUES
        (?, ?, ?, ?, ?, ?, ?, ?, CURDATE());
    `;

    const [result] = await connection.execute(insertQuery, [
      user_id,
      exercise_id,
      name,
      slope,
      y_intercept,
      r_squared,
      type,
      one_rep_max
    ]);
    await connection.end();

    saveTestByWorkout(user_id, result.insertId)

    res.json({
      regression_id: result.insertId // Return the ID of the newly created record
    });
  } catch (error) {
    console.error('Database connection failed:', error);
    res.status(500).send('Error connecting to the database');
  }
});


/*
request body
  {
    exercise_id: 00001,
    name: 'Bench Press',
    type: 'Test', // test or workout
    data: [
      {
        weight : 60,
        max_velocity : 0.58
      },
      {
        weight : 65,
        max_velocity : 0.4
      },
      {
        weight : 70,
        max_velocity : 0.3
      }
    ]
  }

response json
{
  exercise_id: 00001,
  name: 'Bench Press',
  regression: {
    r_squared: 0.9,
    slope: 0.1,
    y_intercept: 0.2
  }
}
*/

router.post('/regression', async (req, res) => {
  const { exercise_id, name, type, data } = req.body;

  try {
    const connection = await createDbConnection();

    const [exercise] = await connection.execute(
      `SELECT one_rep_velocity FROM exercise WHERE exercise_id = ?`,
      [exercise_id]
    );

    if (exercise.length === 0) {
      res.status(404).send('Exercise not found');
      return;
    }

    await connection.end();
    
    const one_rep_velocity = exercise[0].one_rep_velocity;

    const weights = data.map(item => item.weight);
    const velocities = data.map(item => item.max_velocity);

    const N = data.length;
    const sum_x = weights.reduce((acc, x) => acc + x, 0);
    const sum_y = velocities.reduce((acc, y) => acc + y, 0);
    const sum_xy = data.reduce((acc, item) => acc + item.weight * item.max_velocity, 0);
    const sum_x2 = weights.reduce((acc, x) => acc + x * x, 0);

    const a = (N * sum_xy - sum_x * sum_y) / (N * sum_x2 - sum_x ** 2);
    const b = (sum_y - a * sum_x) / N;

    const mean_y = sum_y / N;
    const ss_tot = velocities.reduce((acc, y) => acc + (y - mean_y) ** 2, 0);
    const ss_res = data.reduce((acc, item) => acc + ((item.max_velocity - (a * item.weight + b)) ** 2), 0);
    const r_squared = 1 - (ss_res / ss_tot);

    const one_rep_max = (one_rep_velocity - b) / a;


    res.json({
      exercise_id,
      name,
      regression: {
        one_rep_max: one_rep_max.toFixed(2),
        r_squared: r_squared.toFixed(5),
        slope: a.toFixed(5),
        y_intercept: b.toFixed(5),
        type: type
      },
    });

  } catch (error) {
    console.error('Database connection failed:', error);
    res.status(500).send('Error connecting to the database');
  }
});

/*
request body{
    exercise_id: 00001,
    weight: 60,
    reps: 5,
    units : [1.25, 2.5, 5, 10, 20] 
}
response json{
  exercise_id: 00001,
  one_rep_max: 100,
  three_rep_max: 93,
  test_weights: [65, 70, 85]
}
*/

router.post('/base_weights', async (req, res) => {
  //Brzycki formula
  const { exercise_id, weight, reps, units } = req.body;
  const barWeight = 20;
  const one_rep_max = weight * (36 / (37 - reps));
  const three_rep_max = one_rep_max * 0.93;

  let test_weights = [0.7, 0.8, 0.9].map(x => x * three_rep_max);

  function roundToAvailableWeights(targetWeight) {

    const loadRequired = targetWeight - barWeight;
    if (loadRequired <= 0) return barWeight;
  
    let numericUnits = units.map(unit => parseFloat(unit)).sort((a, b) => b - a);
  
    let bestTotalWeight = barWeight;
    let smallestDifference = Infinity;
  
    const maxCountPerUnit = Math.ceil(loadRequired / numericUnits[numericUnits.length - 1]);
  
    for (let i = 0; i <= maxCountPerUnit; i++) {
      for (let j = 0; j <= maxCountPerUnit; j++) {
        for (let k = 0; k <= maxCountPerUnit; k++) {
          for (let l = 0; l <= maxCountPerUnit; l++) {
            if (numericUnits.length > 3 && i * numericUnits[0] + j * numericUnits[1] + k * numericUnits[2] + l * numericUnits[3] <= loadRequired) {
              let currentTotal = i * numericUnits[0] * 2 + j * numericUnits[1] * 2 + k * numericUnits[2] * 2 + l * numericUnits[3] * 2 + barWeight;
              let currentDifference = Math.abs(targetWeight - currentTotal);
              if (currentDifference < smallestDifference) {
                smallestDifference = currentDifference;
                bestTotalWeight = currentTotal;
              }
            }
          }
        }
      }
    }
  
    return bestTotalWeight;
  }

  test_weights = test_weights.map(roundToAvailableWeights);
  res.json({
    exercise_id,
    one_rep_max: Math.round(one_rep_max),
    three_rep_max: Math.round(three_rep_max),
    test_weights: test_weights.map(Math.round)
  });
});

module.exports = router;