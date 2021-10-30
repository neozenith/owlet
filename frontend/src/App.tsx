import React from 'react';
import './App.css';
import { Account, Status, Login, Signup, Form } from './components';
import dataModel from './datamodel.json';

function App() {
  return (
    <div>
      { Object.entries(dataModel).map(([k, v], index) => <Form key={index} name={k} description={v.description} fields={v.properties} />) }
    </div>
  );
}

export default App;
