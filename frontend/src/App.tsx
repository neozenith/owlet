import React, { useState, useContext, useEffect } from "react";
import './App.css';
import { Account, AccountContext, Status, LandingPage, Form } from './components';
import { Route, Routes } from "react-router-dom";
import dataModel from './datamodel.json';


function App() {

  return (
    <Account>
      <Status />
      <Routes>
        <Route path="/" element={<LandingPage />} />
      { Object.entries(dataModel).map(([k, v], index) => {
          return(
            <Route key={index} path={k} element={<Form name={k} description={v.description} fields={v.properties} />} />
          )
      })}
      </Routes>
    </Account>
  );
}

export default App;
