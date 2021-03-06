import React, { createContext } from "react";
import { CognitoUser, AuthenticationDetails } from "amazon-cognito-identity-js";
import Pool from '../UserPool';

const AccountContext = createContext({} as any);

const Account = (props: any) => {

  const getSession = async () => {
    return await new Promise((resolve, reject) => {
      const user = Pool.getCurrentUser();
      if (user) {
        user.getSession((err: any, session: any) => {
          if (err) {
            reject(err);
          } else {
            // TODO: https://youtu.be/cWJ2rUhbPyA?t=219
            // Get user Attributes
            resolve(session);
          }
        });
      } else {
        reject();
      }
    });

  };

  const authenticate = async (Username: string, Password: string) => {
    return await new Promise((resolve, reject) => {

      const user = new CognitoUser({Username, Pool});
      const authDetails = new AuthenticationDetails({Username, Password});

      user.authenticateUser(authDetails, {
        onSuccess: (data) => {
          console.log("onSuccess: ", data);
          resolve(data);
        },
        onFailure: (err) => {
          console.error("onFailure: ", err);
          reject(err);
        },
        newPasswordRequired: (data) => {
          console.log("newPasswordRequired: ", data);
          resolve(data);
        }
      });
    });
  }

  const logout = () => {
    const user = Pool.getCurrentUser();
    if (user) user.signOut();
  };

  return (
    <AccountContext.Provider value={{ authenticate, getSession, logout }}>
      {props.children}
    </AccountContext.Provider>
  );
};

export { Account, AccountContext };
