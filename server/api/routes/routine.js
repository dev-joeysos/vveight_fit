const express = require('express');
const router = express.Router();

const createDbConnection = require('../db/dbConnection');

//get (done)
router.post('/get', async (req, res) => {
  const { routine_id, user_id } = req.body;

  try {
    const connection = await createDbConnection();

    const [routine] = await connection.execute(
      `SELECT * FROM routines WHERE routine_id = ? AND user_id = ?`,
      [routine_id, user_id]
    );

    if (routine.length === 0) {
      res.status(404).send('Routine not found');
      return;
    }

    const [exercises] = await connection.execute(
      `SELECT * FROM routine_exercises WHERE routine_id = ? ORDER BY \`order\``,
      [routine_id]
    );

    const exerciseWeightsPromises = exercises.map(exercise =>
      connection.execute(
        `SELECT weight FROM exercise_weights WHERE routine_id = ? AND exercise_id = ? ORDER BY set_number`,
        [routine_id, exercise.exercise_id]
      )
    );

    const weightsResults = await Promise.all(exerciseWeightsPromises);

    const exerciseWeights = weightsResults.map(result => result[0].map(weightEntry => weightEntry.weight));

    const exercisesWithWeights = exercises.map((exercise, index) => ({
      ...exercise,
      weights: exerciseWeights[index]  // Now just an array of weights
    }));


    await connection.end();

    res.json({
      routine: routine[0],
      exercises: exercisesWithWeights
    });

  } catch (error) {
    console.error('Database connection failed:', error);
    res.status(500).send('Error connecting to the database');
  }
});



//routines 
/* 
done
request body
{
  routine_id : 00010
  user_id : 00232
}
 
return json
{
  main : 'Bench Press',
  sub : 'Chest Press',
  sub2 : 'Machine Fly',
  date : '2021-06-01',
  target : 'chest'
}
*/

router.post('/getForm', async (req, res) => {
  const { target } = req.body;

  let logDetails = [];  // Array to hold log messages

  try {
    const connection = await createDbConnection();
    logDetails.push(`Database connection successfully established for target: ${target}`);

    const query = 'SELECT exercise_id, name, category, description, target, one_rep_velocity FROM exercise WHERE target = ?';
    const [rows] = await connection.execute(query, [target]);
    await connection.end();

    logDetails.push(`Query executed successfully. Retrieved ${rows.length} exercises.`);

    const main = rows.filter(exercise => exercise.category === 'Compound');
    const sub = rows.filter(exercise => exercise.category === 'Single');

    // Append detailed operation logs
    res.json({
      main,
      sub,
      logs: logDetails  // Sending log details in the response
    });
  } catch (error) {
    // Log and send error details
    console.error(`Database connection failed for target ${target}:`, error);
    logDetails.push(`Error: ${error.message}`);

    res.status(500).json({
      error: "Error connecting to the database",
      logs: logDetails  // Include logs detailing what part of the process failed
    });
  }
});


/* 
done
request body
{
  rotine_id : 00010,
  user_id : 00232
}
 
return json
{
  success : true,
  message : 'Routine deleted successfully'
}
*/

router.post('/delete', async (req, res) => {
  const { routine_id, user_id } = req.body;

  try {
    const connection = await createDbConnection();

    await connection.beginTransaction();

    const checkQuery = 'SELECT routine_id FROM routines WHERE routine_id = ? AND user_id = ?';
    const [existingRoutine] = await connection.execute(checkQuery, [routine_id, user_id]);
    if (existingRoutine.length === 0) {
      await connection.rollback();
      res.status(404).json({ success: false, message: 'Routine not found' });
      return;
    }

    const deleteWeightsQuery = 'DELETE FROM exercise_weights WHERE routine_id = ?';
    await connection.execute(deleteWeightsQuery, [routine_id]);

    const deleteExercisesQuery = 'DELETE FROM routine_exercises WHERE routine_id = ?';
    await connection.execute(deleteExercisesQuery, [routine_id]);

    const deleteRoutineQuery = 'DELETE FROM routines WHERE routine_id = ? AND user_id = ?';
    await connection.execute(deleteRoutineQuery, [routine_id, user_id]);

    await connection.commit();
    await connection.end();

    res.json({ success: true, message: 'Routine and associated exercises deleted successfully' });
  } catch (error) {
    console.error('Database connection failed:', error);
    await connection.rollback();
    res.status(500).send('Error connecting to the database');
  }
});





// add one exercise to routine
router.post('/add', async (req, res) => {
  const { user_id, routine_id, recent_regression_id, exercise_id, order, units } = req.body;

  if (routine_id === undefined || exercise_id === undefined || user_id === undefined || recent_regression_id === undefined || order === undefined) {
    res.status(400).json({ success: false, message: 'Missing required parameters' });
    return;
  }

  try {
    const connection = await createDbConnection();

    const checkQuery = 'SELECT 1 FROM routines WHERE routine_id = ? AND user_id = ?';
    const [routineExists] = await connection.execute(checkQuery, [routine_id, user_id]);

    if (routineExists.length === 0) {
      await connection.rollback();
      await connection.end();
      res.status(403).json({ success: false, message: 'Unauthorized access or routine not found' });
      return;
    }

    const checkExerciseQuery = 'SELECT 1 FROM routine_exercises WHERE routine_id = ? AND exercise_id = ?';
    const [exerciseExists] = await connection.execute(checkExerciseQuery, [routine_id, exercise_id]);

    if (exerciseExists.length > 0) {
      await connection.rollback();
      await connection.end();
      res.status(409).json({ success: false, message: 'Exercise already exists in the routine' });
      return;
    }

    const orderQuery = 'SELECT exercise_id, `order` FROM routine_exercises WHERE routine_id = ? ORDER BY `order`';
    const [currentOrders] = await connection.execute(orderQuery, [routine_id]);

    const updates = currentOrders.filter(ex => ex.order >= order)
      .map(async ex => {
        const updateQuery = 'UPDATE routine_exercises SET `order` = `order` + 1 WHERE routine_id = ? AND exercise_id = ?';
        return connection.execute(updateQuery, [routine_id, ex.exercise_id]);
      });

    await Promise.all(updates);

    const [routineDetails] = await connection.execute(
      `SELECT intensity FROM routines WHERE routine_id = ?`,
      [routine_id]
    );

    const purpose = routineDetails[0].intensity;

    const [regressionResults] = await connection.execute(
      `SELECT one_rep_max FROM regression_results WHERE regression_id = ?`,
      [recent_regression_id]
    );

    const one_rep_max = regressionResults[0].one_rep_max;
    let defaults = { sets: 5, rest_period: 90, intensity: 'hypertrophy' };
    let weightRatios = [];

    const [exerciseCategory] = await connection.execute(
      `SELECT category FROM exercise WHERE exercise_id = ?`,
      [exercise_id]
    );
    
    switch (purpose) {
      case 'hypertrophy':
        defaults = { sets: 5, rest_period: 90, intensity: 'hypertrophy' };
        weightRatios = [0.6, 0.65, 0.65, 0.7, 0.65];
        break;
      case 'endurance':
        defaults = { sets: 3, rest_period: 30, intensity: 'endurance' };
        weightRatios = [0.40, 0.45, 0.50];
        break;
      case 'strength':
        defaults = { sets: 3, rest_period: 120, intensity: 'strength' };
        weightRatios = [0.70, 0.75, 0.80];
        break;
    }

    const barWeight = 20
    const weights = weightRatios.map(ratio => roundToAvailableWeights(one_rep_max * ratio, barWeight, units));

    let Query1 = ''
    let Query2 = ''
    let targets = 0

    if (exerciseCategory[0].category == 'Compound') {
      Query1 = `INSERT INTO routine_exercises (routine_id, exercise_id, \`order\`, sets, rest_period, intensity, target_velocity) VALUES (?, ?, ?, ?, ?, ?, ?)`
      Query2 = `INSERT INTO exercise_weights (routine_exercise_id, routine_id, exercise_id, set_number, weight) VALUES (?, ?, ?, ?, ?)`
      targets = 0.30
    } else if (exerciseCategory[0].category == 'Single') {
      Query1 = `INSERT INTO routine_exercises (routine_id, exercise_id, \`order\`, sets, rest_period, intensity, reps) VALUES (?, ?, ?, ?, ?, ?, ?)`
      Query2 = `INSERT INTO exercise_weights (routine_exercise_id, routine_id, exercise_id, set_number, weight) VALUES (?, ?, ?, ?, ?)` // will be changed later by algorithm
      targets = 15
    }

    const [exerciseResult] = await connection.execute(Query1, [
      routine_id,
      exercise_id,
      order,
      defaults.sets,
      defaults.rest_period,
      defaults.intensity,
      targets
    ]);

    const [rows] = await connection.execute(
      'SELECT MAX(routine_exercise_id) AS max_routine_exercise_id FROM exercise_weights WHERE routine_id = ? AND exercise_id = ?',
      [routine_id, exercise_id]
    );
    
    const routineExerciseId = exerciseResult.insertId;
    
    const maxRoutineExerciseId = rows[0].routine_exercise_id + 1
    const weightInsertQueries = weights.map((weight, index) => connection.execute(
      Query2,
      [routineExerciseId, routine_id, exercise_id, index + 1, weight]
    ));


    await Promise.all(weightInsertQueries);

    await connection.commit();
    await connection.end();
    res.json({ success: true, message: 'Exercise added successfully' });
  } catch (error) {
    console.error('Database connection failed:', error);
    await connection.rollback();
    res.status(500).send('Error connecting to the database');
  }
});



router.post('/create', async (req, res) => {
  const { user_id, routine_name, target, purpose, recent_regression_id, main, sub, units } = req.body;
  const barWeight = 20;

  try {
    const connection = await createDbConnection();

    const [regressionResults] = await connection.execute(
      `SELECT one_rep_max FROM regression_results WHERE regression_id = ?`,
      [recent_regression_id]
    );

    if (regressionResults.length === 0) {
      res.status(404).send('Regression data not found');
      return;
    }

    const one_rep_max = regressionResults[0].one_rep_max;
    let defaults = { sets: 5, rest_period: 90, intensity: 'hypertrophy' };
    let weightRatios = [];

    switch (purpose) {
      case 'hypertrophy':
        defaults = { sets: 5, rest_period: 90, intensity: 'hypertrophy' };
        weightRatios = [0.6, 0.65, 0.65, 0.7, 0.65];
        break;
      case 'endurance':
        defaults = { sets: 3, rest_period: 30, intensity: 'endurance' };
        weightRatios = [0.40, 0.45, 0.50];
        break;
      case 'strength':
        defaults = { sets: 3, rest_period: 120, intensity: 'strength' };
        weightRatios = [0.70, 0.75, 0.80];
        break;
    }

    const routineQuery = `INSERT INTO routines (user_id, routine_name, target, intensity, creation_date) VALUES (?, ?, ?, ?, CURDATE())`;
    const [routineResult] = await connection.execute(routineQuery, [user_id, routine_name, target, purpose]);
    const routine_id = routineResult.insertId;

    const weights = weightRatios.map(ratio => roundToAvailableWeights(one_rep_max * ratio, barWeight, units));

    const mainExercises = main.map((id, index) => ({
      routine_id,
      exercise_id: id,
      order: index,
      sets: defaults.sets,
      rest_period: defaults.rest_period,
      intensity: defaults.intensity,
      weight: weights[index % weights.length]
    }));

    for (const exercise of mainExercises) {
      const exerciseQuery = `INSERT INTO routine_exercises (routine_id, exercise_id, \`order\`, sets, rest_period, intensity, target_velocity) VALUES (?, ?, ?, ?, ?, ?, ?)`;
      const [exerciseResult] = await connection.execute(exerciseQuery, [
        exercise.routine_id,
        exercise.exercise_id,
        exercise.order,
        exercise.sets,
        exercise.rest_period,
        exercise.intensity,
        0.30
      ]);

      const routineExerciseId = exerciseResult.insertId;

      for (const [index, weight] of weights.entries()) {
        const weightInsertQuery = `INSERT INTO exercise_weights (routine_exercise_id, routine_id, exercise_id, set_number, weight) VALUES (?, ?, ?, ?, ?)`;
        await connection.execute(weightInsertQuery, [
          routineExerciseId, //parseInt(`${routine_id}${exercise.exercise_id}${index + 1}`),
          exercise.routine_id,
          exercise.exercise_id,
          index + 1,
          weight
        ]);
      }
    }


    const subExercises = sub.map((id, index) => ({
      routine_id,
      exercise_id: id,
      order: index + main.length,
      sets: defaults.sets,
      rest_period: defaults.rest_period,
      intensity: defaults.intensity
    }));

    for (const exercise of subExercises) {
      const exerciseQuery = `INSERT INTO routine_exercises (routine_id, exercise_id, \`order\`, sets, rest_period, intensity, reps) VALUES (?, ?, ?, ?, ?, ?, ?)`;
      const [exerciseResult] = await connection.execute(exerciseQuery, [
        exercise.routine_id,
        exercise.exercise_id,
        exercise.order,
        exercise.sets,
        exercise.rest_period,
        exercise.intensity,
        15
      ]);

      const routineExerciseId = exerciseResult.insertId;


      for (const [index, weight] of weights.entries()) {
        const weightInsertQuery = `INSERT INTO exercise_weights (routine_exercise_id, routine_id, exercise_id, set_number, weight) VALUES (?, ?, ?, ?, ?)`;
        await connection.execute(weightInsertQuery, [
          routineExerciseId,
          exercise.routine_id,
          exercise.exercise_id,
          index + 1,
          weight
        ]);
      }
    }

    await connection.end();

    res.json({ success: true, message: 'Routine saved successfully', routine_id: routine_id });
  } catch (error) {
    console.error('Database connection failed:', error);
    res.status(500).send('Error connecting to the database');
  }
});


router.post('/recommend', async (req, res) => {
  try {

  } catch (error) {
    console.error('Database connection failed:', error);
    res.status(500).send('Error connecting to the database');
  }
});

module.exports = router;


function roundToAvailableWeights(targetWeight, barWeight, units) {

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