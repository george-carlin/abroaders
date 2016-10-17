import React from "react";

import RadioButton from "../../core/RadioButton";
import PersonName  from "../PersonName";

const AccountPeopleNames = (_props) => {
  const props     = Object.assign({}, _props);
  const owner     = props.account.owner;
  const companion = props.account.companion;

  if (companion) {
    return (
      <p className="people-names">
        <PersonName
          person={owner}
          withRadio
          selected={owner === props.selectedPerson}
          onChange={props.onChooseOwner}
        />
        <PersonName
          person={companion}
          withRadio
          selected={companion === props.selectedPerson}
          onChange={props.onChooseCompanion}
        />
      </p>
    );
  } else {
    return (
      <PersonName
        person={owner}
        withRadio={false}
      />
    );
  }
};

AccountPeopleNames.propTypes = Object.assign(
  {
    account: React.PropTypes.object.isRequired,
    selectedPerson: React.PropTypes.object.isRequired,
    onChooseOwner: React.PropTypes.func.isRequired,
    onChooseCompanion: React.PropTypes.func.isRequired,
  }
);

export default AccountPeopleNames;
