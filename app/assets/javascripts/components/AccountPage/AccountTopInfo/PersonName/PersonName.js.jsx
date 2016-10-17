import React from "react";

import RadioButton  from "../../../core/RadioButton";
import PersonStatus from "../PersonStatus";

const PersonName = (_props) => {
  const props = Object.assign({}, _props);
  const person = props.person;

  if (props.withRadio) {
    return (
      <label className="radio-inline">
        <RadioButton
          onChange={props.onChange}
          attribute="spending_info"
          modelName="account"
          value={person.main ? "owner" : "companion"}
          checked={props.selected}
        />

        {person.firstName}

        <PersonStatus
          person={person}
        />
      </label>
    );
  } else {
    return (
      <h1>
        {person.firstName}

        <PersonStatus
          person={person}
        />
      </h1>
    );
  }
};

PersonName.propTypes = Object.assign(
  {
    person: React.PropTypes.object.isRequired,
    withRadio: React.PropTypes.bool.isRequired,
    selected: React.PropTypes.bool,
    onChange: React.PropTypes.func,
  }
);

export default PersonName;
