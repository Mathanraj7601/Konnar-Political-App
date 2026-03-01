const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

// Mock data storage
let registrations = [];
let nextId = 1;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes

// Get all registrations (Admin only)
app.get('/api/registrations', (req, res) => {
  res.json({
    success: true,
    data: registrations
  });
});

// Create new registration
app.post('/api/registrations', (req, res) => {
  const {
    fullName,
    email,
    phone,
    partyName,
    partySymbol,
    partyColors,
    partyIdeology,
    partyVision,
    partyMission,
    partyLeader,
    partyFounded,
    partyHeadquarters,
    partyWebsite
  } = req.body;

  // Validation
  if (!fullName || !email || !phone || !partyName || !partySymbol) {
    return res.status(400).json({
      success: false,
      message: 'Required fields are missing'
    });
  }

  const newRegistration = {
    id: nextId++,
    fullName,
    email,
    phone,
    partyName,
    partySymbol,
    partyColors,
    partyIdeology,
    partyVision,
    partyMission,
    partyLeader,
    partyFounded,
    partyHeadquarters,
    partyWebsite,
    status: 'pending',
    submittedAt: new Date().toISOString(),
    reviewedAt: null
  };

  registrations.push(newRegistration);

  res.json({
    success: true,
    message: 'Registration submitted successfully!',
    data: newRegistration
  });
});

// Update registration status (Admin only)
app.put('/api/registrations/:id/status', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  
  const registration = registrations.find(r => r.id === parseInt(id));
  
  if (!registration) {
    return res.status(404).json({
      success: false,
      message: 'Registration not found'
    });
  }

  registration.status = status;
  registration.reviewedAt = new Date().toISOString();

  res.json({
    success: true,
    message: `Registration ${status} successfully`,
    data: registration
  });
});

// Get registration by ID
app.get('/api/registrations/:id', (req, res) => {
  const { id } = req.params;
  const registration = registrations.find(r => r.id === parseInt(id));
  
  if (!registration) {
    return res.status(404).json({
      success: false,
      message: 'Registration not found'
    });
  }

  res.json({
    success: true,
    data: registration
  });
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Backend is running',
    timestamp: new Date().toISOString()
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Political Party Registration Backend running on port ${PORT}`);
  console.log(`API endpoints available at http://localhost:${PORT}/api`);
});