import React, {useEffect, useContext, useState } from 'react'
import { AccountContext } from "./Account";
import Login from "./Login";
import Signup from "./Signup";
import dataModel from '../datamodel.json';

const LandingPage = (props: any) => {
    const { getSession } = useContext(AccountContext);
    const [loggedIn, setLoggedIn] = useState(false);

    useEffect(() => {
        getSession().then(() => setLoggedIn(true));
    }, []);

    if (loggedIn) {
      return(
      <ul> 
      { Object.entries(dataModel).map(([k, v], index) => {
          return(
            <li key={index}><a href={k}>{k}</a></li>
          )
      })}
      </ul>

      )
    } else {
      return(
        <div>
          <Login />
          <Signup />
        </div>
      )
    }
        
}

export default LandingPage
