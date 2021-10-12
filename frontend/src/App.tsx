import React from 'react';
import './App.css';
import { Account, Status, Login, Signup } from './components';

function App() {
  return (
    <Account>
      <Status />
      <Signup />
      <Login />
    </Account>
  );
}

export default App;
