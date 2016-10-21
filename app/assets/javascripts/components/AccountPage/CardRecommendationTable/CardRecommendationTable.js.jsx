import React from "react";

import Row            from "../../core/Row";
import CardAccountRow from "./CardAccountRow";

const CardRecommendationTable = (_props) => {
  const props = Object.assign({}, _props);
  const person = props.person;

  return (
    <div className="col-xs-12 col-md-6">
      <p>{person.firstName}'s Credit Cards</p>

      <div className="table-wrapper">
        <table id="admin_person_card_accounts_table" className="table table-striped">
          <thead>
            <tr>
              <th>ID</th>
              <th>Bank</th>
              <th>Name</th>
              <th>Status</th>
              <th>Applied</th>
              <th>Opened</th>
              <th>Closed</th>
            </tr>
          </thead>

          <tbody>
            { person.cardAccounts.map(cardAccount => (
              <CardAccountRow
                key={cardAccount.id}
                cardAccount={cardAccount}
              />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

CardRecommendationTable.propTypes = Object.assign(
  {
    person: React.PropTypes.object.isRequired,
  }
);

export default CardRecommendationTable;
