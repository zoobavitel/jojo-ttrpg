// src/index.js
const express = require('express');
const authRoutes = require('./routes/auth');
const characterRoutes = require('./routes/characters');

const app = express();

// Middleware
app.use(express.json());

// Routes
app.use('/auth', authRoutes);
app.use('/characters', characterRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'JoJo TTRPG API Running!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});