import React, { useState, useContext, useEffect } from "react";
import './App.css';
import { Account, AccountContext, Status, LandingPage, Form } from './components';
import dataModel from './datamodel.json';


function App() {

  return (
    <Account>

      <Status />
      <LandingPage />
      { Object.entries(dataModel).map(([k, v], index) => {
          return(
          <Form key={index} name={k} description={v.description} fields={v.properties} />
          )
      })}
    </Account>
  );
}

export default App;
