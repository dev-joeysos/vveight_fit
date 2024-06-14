//workout.js
const express = require('express');
const router = express.Router();

const createDbConnection = require('../db/dbConnection');

async function calculateRegression(exercise_id, type, data) {
    try {
        console.log(data);
        console.log(typeof(data));

        data = data.map(item => ({
            weight: parseFloat(item.weight),
            mean_velocity: parseFloat(item.mean_velocity)
        }));

        const connection = await createDbConnection();
        const [exercise] = await connection.execute(
            `SELECT one_rep_velocity FROM exercise WHERE exercise_id = ?`,
            [exercise_id]
        );

        await connection.end();

        if (exercise.length === 0) {
            return false;
        }

        const one_rep_velocity = exercise[0].one_rep_velocity;
        const weights = data.map(item => item.weight);
        const velocities = data.map(item => item.mean_velocity);

        const N = data.length;
        const sum_x = weights.reduce((acc, x) => acc + x, 0);
        const sum_y = velocities.reduce((acc, y) => acc + y, 0);
        const sum_xy = data.reduce((acc, item) => acc + item.weight * item.mean_velocity, 0);
        const sum_x2 = weights.reduce((acc, x) => acc + x * x, 0);

        const a = (N * sum_xy - sum_x * sum_y) / (N * sum_x2 - sum_x ** 2);
        const b = (sum_y - a * sum_x) / N;

        const mean_y = sum_y / N;
        const ss_tot = velocities.reduce((acc, y) => acc + (y - mean_y) ** 2, 0);
        const ss_res = data.reduce((acc, item) => acc + ((item.mean_velocity - (a * item.weight + b)) ** 2), 0);
        const r_squared = 1 - (ss_res / ss_tot);

        const one_rep_max = (one_rep_velocity - b) / a;

        return {
            one_rep_max: one_rep_max.toFixed(2),
            r_squared: r_squared.toFixed(5),
            slope: a.toFixed(5),
            y_intercept: b.toFixed(5),
            type: type
        };

    } catch (error) {
        console.error(error);
        return false;
    }
}

async function getregression(exercise_id, user_id, regression_id) {
    try {
        const connection = await createDbConnection();
        const query = `
          SELECT creation_date AS date, r_squared, slope, y_intercept, type, one_rep_max
          FROM regression_results
          WHERE exercise_id = ? AND user_id = ? AND regression_id = ?`;

        const [rows] = await connection.execute(query, [exercise_id, user_id, regression_id]);
        await connection.end();

        if (rows.length > 0) {
            return rows[0];
        } else {
            return false
        }
    } catch (error) {
        return false
    }
}

async function getregressionWithoutExercise(user_id, regression_id) {
    try {
        const connection = await createDbConnection();
        const query = `
          SELECT creation_date AS date, r_squared, slope, y_intercept, type, one_rep_max, exercise_id
          FROM regression_results
          WHERE user_id = ? AND regression_id = ?`;

        const [rows] = await connection.execute(query, [user_id, regression_id]);
        await connection.end();

        if (rows.length > 0) {
            return rows[0];
        } else {
            return false
        }
    } catch (error) {
        return false
    }
}

async function compareOneRepMax(exercise_id, test_one_rep_max, workout_one_rep_max) {
    const percentile = workout_one_rep_max / test_one_rep_max;
    switch (exercise_id) {
        case '00001': // Bench Press
            if (percentile < 0.90) {
                return 'exhausted';
            } else if (0.90 <= percentile && percentile < 1.05) {
                return 'normal';
            } else if (1.05 <= percentile && percentile < 1.15) {
                return 'burning';
            } else if (1.15 <= percentile) {
                return 'test Required';
            } else {
                return false;
            }
        case '00004': // conventional deadlift
            if (percentile < 0.90) {
                return 'exhausted';
            } else if (0.90 <= percentile && percentile < 1.05) {
                return 'normal';
            } else if (1.05 <= percentile && percentile < 1.15) {
                return 'burning';
            } else if (1.15 <= percentile) {
                return 'test Required';
            } else {
                return false;
            }
        case '00009': // overhead press
            if (percentile < 0.90) {
                return 'exhausted';
            } else if (0.90 <= percentile && percentile < 1.05) {
                return 'normal';
            } else if (1.05 <= percentile && percentile < 1.15) {
                return 'burning';
            } else if (1.15 <= percentile) {
                return 'test Required';
            } else {
                return false;
            }
        case '00010': // back squat
            if (percentile < 0.90) {
                return 'exhausted';
            } else if (0.90 <= percentile && percentile < 1.05) {
                return 'normal';
            } else if (1.05 <= percentile && percentile < 1.15) {
                return 'burning';
            } else if (1.15 <= percentile) {
                return 'test Required';
            } else {
                return false;
            }
        default:
            return false;
    }
}

async function saveRegression(user_id, exercise_id, name, regression) {
    try {
        const { r_squared, slope, y_intercept, type, one_rep_max } = regression;
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

        return result.insertId // Return the ID of the newly created record
    } catch (error) {
        return false;
    }
}

async function getAllWorkouts(user_id) {
    try {
        const connection = await createDbConnection();
        const query = `
          SELECT workout_id, status, date
          FROM workout
          WHERE user_id = ?`;

        const [rows] = await connection.execute(query, [user_id]);
        await connection.end();

        if (rows.length > 0) {
            return rows;
        } else {
            return false
        }
    } catch (error) {
        return false
    }
}

async function getWorkoutDetails(user_id, workout_id) {
    try {
        const connection = await createDbConnection();
        const query = `
          SELECT routine_id, test_regression_id, workout_regression_id, status, date
          FROM workout
          WHERE user_id = ? AND workout_id = ?`;

        const [rows] = await connection.execute(query, [user_id, workout_id]);
        await connection.end();

        if (rows.length > 0) {
            return rows[0];
        } else {
            return false
        }
    } catch (error) {
        return false
    }
}
/*
{
    ‘user_id’ : ‘00001’,
    ‘test_regression_id’ : ‘00001’
    'exercise_id': '00001', 
    ‘name’ : ‘Bench Press’,
    'data': [{data1}, {data2}, {data3}]
} 
*/

router.post('/compare', async (req, res) => {
    const { user_id, exercise_id, test_regression_id, name, data } = req.body;
    const type = 'workout';
    console.log('outer : ', data)

    const workout_result = await calculateRegression(exercise_id, type, data);
    console.log ('workout_result : ', workout_result)
    const test_result = await getregression(exercise_id, user_id, test_regression_id);
    const status = await compareOneRepMax(exercise_id, test_result.one_rep_max, workout_result.one_rep_max);

    const return_data = {
        user_id: user_id,
        exercise_id: exercise_id,
        name: name,
        test_regression: test_result,
        workout_regression: workout_result,
        status: status
    }
    res.status(200).json(return_data);
});

router.post('/save', async (req, res) => {
    const { user_id, exercise_id, exercise_name, test_regression_id, workout_regression_data, status, routine_id } = req.body;
    const workout_regression_id = await saveRegression(user_id, exercise_id, exercise_name, workout_regression_data);

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

        res.json({
            workout_id: result.insertId
        });
    } catch (error) {
        console.error('Database connection failed:', error);
        res.status(500).send('Error connecting to the database');
    }
});

router.post('/getDetails', async (req, res) => {
    const { user_id, workout_id} = req.body;
    const data = await getWorkoutDetails(user_id, workout_id);

    if (data) {
        test_regression = await getregressionWithoutExercise(user_id, data.test_regression_id);
        workout_regression = await getregressionWithoutExercise(user_id, data.workout_regression_id);

        let response = {
            workout_id: workout_id,
            routine_id: data.routine_id,
            exercise_id: workout_regression.exercise_id,
            test_regression: test_regression,
            workout_regression: workout_regression,
            status: data.status,
            date: data.date
        }

        res.status(200).json(response);
    } else {
        res.status(404).send('No workout found');
    }
});

router.post('/getAll', async (req, res) => {
    const { user_id } = req.body;
    data = await getAllWorkouts(user_id);
    if (data) {
        res.status(200).json(data);
    } else {
        res.status(404).send('No workouts found');
    }
});

module.exports = router;