import React, {useEffect, useContext, useState } from 'react'
import { AccountContext } from "./Account";
import Login from "./Login";
import Signup from "./Signup";

const LandingPage = (props: any) => {
    const { getSession } = useContext(AccountContext);
    const [loggedIn, setLoggedIn] = useState(false);

    useEffect(() => {
        getSession().then(() => setLoggedIn(true));
    }, []);

    return (
      <div>
        { !loggedIn && <Login /> }
        { !loggedIn && <Signup /> }
      </div>
    )
}

export default LandingPage
