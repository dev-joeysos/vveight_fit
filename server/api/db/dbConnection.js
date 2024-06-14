const mysql = require('mysql2/promise');
const dbConfig = require('./dbConfig');

async function createDbConnection() {
  try {
    const connection = await mysql.createConnection(dbConfig);
    return connection;
  } catch (error) {
    console.error('Database connection failed:', error);
    throw error;
  }
}

module.exports = createDbConnection;
