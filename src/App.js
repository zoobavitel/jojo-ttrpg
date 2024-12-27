import React, { useEffect, useState } from 'react';
import io from 'socket.io-client';

const socket = io('http://localhost:3001');

function App() {
  const [rollResult, setRollResult] = useState(null);

  const rollDice = () => {
    socket.emit('roll', { action: 'Skirmish', dice: 3 });
  };

  useEffect(() => {
    socket.on('roll-result', (data) => {
      setRollResult(data.result);
    });
    return () => socket.off('roll-result');
  }, []);

  return (
    <div>
      <h1>JoJo TTRPG</h1>
      <button onClick={rollDice}>Roll Dice</button>
      {rollResult && <p>Dice Result: {rollResult}</p>}
    </div>
  );
}

export default App;
