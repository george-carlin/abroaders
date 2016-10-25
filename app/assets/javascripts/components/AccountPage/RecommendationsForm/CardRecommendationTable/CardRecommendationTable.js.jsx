import React from "react";

import Row            from "../../../core/Row";
import CardAccountRow from "./CardAccountRow";

const CardRecommendationTable = React.createClass({
  propTypes: {
    person: React.PropTypes.object.isRequired,
    cardAccounts: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
  },

  render() {
    return (
      <div className="col-xs-12 col-md-6">
        <p>{this.props.person.firstName}'s Credit Cards</p>

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
            { this.props.cardAccounts.map(cardAccount => (
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
  },
});

export default CardRecommendationTable;
