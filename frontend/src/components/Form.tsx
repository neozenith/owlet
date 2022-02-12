import React from 'react'

const Form = (props: any) => {
    const fields = props.fields as Array<{name: string, type: string}>;

    const inputTypeForFieldType = (fieldType: string): string => {
        return "text"
    };

    return (
        <div>
            <h3>{props.name}</h3>
            <div>{props.description}</div>
            <form>
                
            {
                fields.map((field, index) => {
                    return(
                        <div>
                        <label>{field.name}</label>
                        <input key={index} id={field.name} value="" type={inputTypeForFieldType(field.type)} />
                        </div>
                    );
                })
            }

            <input type="submit" />
                
            </form>

        </div>
    )
}

export default Form
