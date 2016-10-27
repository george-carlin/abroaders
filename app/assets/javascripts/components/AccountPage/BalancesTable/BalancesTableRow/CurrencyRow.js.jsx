import React from "react";

import Row from "../../../core/Row";

const CurrencyRow = React.createClass({
  propTypes: {
    currency: React.PropTypes.object.isRequired,
    account: React.PropTypes.object.isRequired,
  },

  getPersonBalance(person) {
    const personBalance = this.props.currency.balances.find(balance => {
      return balance.personId === person.id;
    });

    if (personBalance) {
      return personBalance.value;
    } else {
      return 0;
    }
  },

  render() {
    const currency  = this.props.currency;
    const account   = this.props.account;
    const companion = account.companion;

    const currencyClass = companion ? "currency" : "currency without-companion";
    return (
      <Row className="currency-row">
        <div className={currencyClass}>{currency.name}</div>
        <div className="balance">{this.getPersonBalance(account.owner)}</div>

        {(() => {
          if (companion) {
            return (
              <div className="balance">{this.getPersonBalance(companion)}</div>
            );
          }
        })()}

      </Row>
    );
  },
});

export default CurrencyRow;
