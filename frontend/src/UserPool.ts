import { CognitoUserPool } from "amazon-cognito-identity-js";
import poolData from './userpool-config.json'

export default new CognitoUserPool(poolData);
