import React, {useEffect, useContext, useState } from 'react'
import { AccountContext } from "./Account";

const Form = (props: any) => {
    const { getSession } = useContext(AccountContext);
    const [loggedIn, setLoggedIn] = useState(false);

    useEffect(() => {
        getSession().then(() => setLoggedIn(true));
    }, []);

    const fields = props.fields as Array<{name: string, type: string}>;

    const inputTypeForFieldType = (fieldType: string): string => {
        return "text"
    };
    if (loggedIn) {
    return (
        <div>
            <h3>{props.name}</h3>
            <div>{props.description}</div>
            <form>
                
            { fields.map((field, index) => {
                    return(
                        <div key={`div-${index}`}>
                        <label key={`label-${index}`} htmlFor={field.name}>{field.name}</label>
                        <input key={index} id={field.name} value="" type={inputTypeForFieldType(field.type)} />
                        </div>
                    );
                })
            }

            <input type="submit" />
                
            </form>

        </div>
    )
    } else {
        return(<div></div>)
    }
}

export default Form
