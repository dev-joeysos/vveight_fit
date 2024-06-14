const express = require('express');
const app = express();

app.use(express.json());

const loginRoutes = require('./api/routes/login');
const vbtCoreRoutes = require('./api/routes/vbt_core');
const exerciseRoutes = require('./api/routes/exercise');
const routineRoutes = require('./api/routes/routine');
const workoutRoutes = require('./api/routes/workout');

app.use('/api/login', loginRoutes);        
app.use('/api/vbt_core', vbtCoreRoutes);   
app.use('/api/exercise', exerciseRoutes);  
app.use('/api/routine', routineRoutes);
app.use('/api/workout', workoutRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

