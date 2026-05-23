const express = require('express');
const cors = require('cors');
require('dotenv').config();

const sellersRoutes = require('./routes/sellers');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/sellers', sellersRoutes);

app.get('/', (req, res) => {
  res.send('CharloTech API Running');
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
