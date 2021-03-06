import React, { useState } from "react";
import UserPool from '../UserPool';

const Signup = () => {

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const onSubmit = (event: any) => {
    event.preventDefault();
    UserPool.signUp(email, password, [], [], (err, data) => {
      if (err) console.log(err);
      console.log(data);
    });
  };

  return (
    <div id="signup">
      <form onSubmit={onSubmit}>
        <label htmlFor="email">Email</label>
        <input value={email} onChange={(event) => setEmail(event.target.value)}></input>
        <label htmlFor="password">Password</label>
        <input type="password" value={password} onChange={(event) => setPassword(event.target.value)}></input>
        <button type="submit">Signup</button>
      </form>
    </div>
  );
};

export default Signup;
