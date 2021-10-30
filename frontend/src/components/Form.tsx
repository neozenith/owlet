import React from 'react'

const Form = (props: any) => {
    const fields = props.fields as Array<{name: string, type: string}>;

    return (
        <div>
            <h3>{props.name}</h3>
            <div>{props.description}</div>
            <ul>
                { fields.map((field, index) => <li key={index}>{field.name}: {field.type}</li>) }
            </ul>

        </div>
    )
}

export default Form
