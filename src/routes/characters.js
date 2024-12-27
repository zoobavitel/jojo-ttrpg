// src/routes/characters.js
const express = require('express');
const router = express.Router();
const prisma = require('../db/client'); // Database client
const authMiddleware = require('../middleware/auth'); // Authentication middleware

// Validation constants
const VALID_STAND_GRADES = ['S', 'A', 'B', 'C', 'D', 'F'];

// Validation functions
const validateStandStats = (stand) => {
  const stats = ['power', 'speed', 'range', 'durability', 'precision', 'potential'];
  const totalPoints = stats.reduce((sum, stat) => {
    if (!VALID_STAND_GRADES.includes(stand[stat])) {
      throw new Error(`Invalid grade for ${stat}: must be S, A, B, C, D, or F`);
    }
    const points = stand[stat] === 'S' ? 5 : 
                  stand[stat] === 'A' ? 4 :
                  stand[stat] === 'B' ? 3 :
                  stand[stat] === 'C' ? 2 :
                  stand[stat] === 'D' ? 1 : 0;
    return sum + points;
  }, 0);
  if (totalPoints > 10) {
    throw new Error('Total points exceed 10');
  }
};

// Utility function for calculating durability effects
const calculateDurabilityEffects = (durabilityGrade) => {
  const BASE_STRESS = 9;
  const effects = {
    'S': { stressModifier: 4, specialArmor: 4 },
    'A': { stressModifier: 3, specialArmor: 3 },
    'B': { stressModifier: 2, specialArmor: 2 },
    'C': { stressModifier: 1, specialArmor: 1 },
    'D': { stressModifier: 0, specialArmor: 1 },
    'F': { stressModifier: -3, specialArmor: 0 }
  };

  const { stressModifier, specialArmor } = effects[durabilityGrade] || { stressModifier: 0, specialArmor: 0 };
  return {
    maxStress: Math.max(0, BASE_STRESS + stressModifier),
    specialArmor
  };
};

// Validate action dots
const validateActionDots = (character) => {
  const totalDots = Object.keys(character).reduce((sum, action) => {
    if (['hunt', 'study', 'survey', 'tinker', 'finesse', 'prowl', 'skirmish', 'wreck', 'bizarre', 'command', 'consort', 'sway'].includes(action)) {
      return sum + character[action];
    }
    return sum;
  }, 0);

  if (totalDots > 7) {
    throw new Error('Total action dots cannot exceed 7');
  }

  // No action can exceed 2 dots at character creation
  Object.keys(character).forEach(action => {
    if (character[action] > 2) {
      throw new Error(`Action ${action} cannot exceed 2 dots at character creation`);
    }
  });
};

// Middleware for all character routes
router.use(authMiddleware);

// Create character
router.post('/', async (req, res) => {
  try {
    const { name, origin, vice, vicePurveyor, friends, rivals, stand, ...actions } = req.body;

    // Validate stand stats and action dots
    if (stand) validateStandStats(stand);
    validateActionDots(actions);

    // Calculate stress and armor effects based on durability
    const durabilityEffects = stand ? calculateDurabilityEffects(stand.durability) : { maxStress: 9, specialArmor: 0 };

    const character = await prisma.character.create({
      data: {
        userId: req.user.id,
        name,
        origin,
        vice,
        vicePurveyor,
        friends,
        rivals,
        ...actions,
        maxStress: durabilityEffects.maxStress,
        specialArmor: durabilityEffects.specialArmor,
        stress: 0,
        stand: stand ? {
          create: { ...stand }
        } : undefined
      },
      include: { stand: true }
    });

    res.status(201).json({ message: 'Character created successfully', character });
  } catch (error) {
    console.error('Error creating character:', error);
    res.status(500).json({ message: error.message });
  }
});

// Get all characters
router.get('/', async (req, res) => {
  try {
    const characters = await prisma.character.findMany({
      where: { userId: req.user.id },
      include: { stand: true }
    });
    res.json(characters);
  } catch (error) {
    console.error('Error fetching characters:', error);
    res.status(500).json({ message: 'Error fetching characters' });
  }
});

// Get a specific character
router.get('/:id', async (req, res) => {
  try {
    const character = await prisma.character.findUnique({
      where: { id: req.params.id },
      include: { stand: true }
    });

    if (!character) return res.status(404).json({ message: 'Character not found' });
    if (character.userId !== req.user.id) return res.status(403).json({ message: 'Unauthorized' });

    res.json(character);
  } catch (error) {
    console.error('Error fetching character:', error);
    res.status(500).json({ message: 'Error fetching character' });
  }
});

// Delete character
router.delete('/:id', async (req, res) => {
  try {
    const character = await prisma.character.findUnique({ where: { id: req.params.id } });

    if (!character) return res.status(404).json({ message: 'Character not found' });
    if (character.userId !== req.user.id) return res.status(403).json({ message: 'Unauthorized' });

    await prisma.character.delete({ where: { id: req.params.id } });
    res.json({ message: 'Character deleted successfully' });
  } catch (error) {
    console.error('Error deleting character:', error);
    res.status(500).json({ message: 'Error deleting character' });
  }
});

// Update character
router.patch('/:id', async (req, res) => {
  try {
    const { stress, harm, specialArmor } = req.body;
    const character = await prisma.character.findUnique({ where: { id: req.params.id } });

    if (!character) return res.status(404).json({ message: 'Character not found' });
    if (character.userId !== req.user.id) return res.status(403).json({ message: 'Unauthorized' });

    const updatedCharacter = await prisma.character.update({
      where: { id: req.params.id },
      data: { stress, harm, specialArmor },
      include: { stand: true }
    });

    res.json(updatedCharacter);
  } catch (error) {
    console.error('Error updating character:', error);
    res.status(500).json({ message: 'Error updating character' });
  }
});

module.exports = router;
