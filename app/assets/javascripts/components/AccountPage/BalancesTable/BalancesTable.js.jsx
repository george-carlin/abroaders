import React from "react";

import Row from "../../core/Row";
import BalancesTableRow from "./BalancesTableRow";

const BalancesTable = React.createClass({
  propTypes: {
    alliances: React.PropTypes.array.isRequired,
    account: React.PropTypes.object.isRequired,
  },

  getCurrenciesByAlliance() {
    const alliances = [];

    this.props.alliances.forEach(allianceString => {
      const alliance = JSON.parse(allianceString);
      const allianceWithCurrencies = { id: alliance.id, name: alliance.name, currencies: [] };

      this.props.account.balancesByCurrencies.forEach((currencyWithBalances) => {
        const currency = currencyWithBalances[0];
        const balancesArray = currencyWithBalances[1];

        if (currency.allianceId === allianceWithCurrencies.id) {
          const currencyObject = { id: currency.id, name: currency.name, balances: balancesArray };
          allianceWithCurrencies.currencies.push(currencyObject);
        }
      });
      alliances.push(allianceWithCurrencies);
    });

    return alliances;
  },

  getCurrenciesByType(type) {
    const currencies = [];

    this.props.account.balancesByCurrencies.forEach((currencyWithBalances) => {
      const currency = currencyWithBalances[0];
      const balancesArray = currencyWithBalances[1];

      if ((currency.type === type) || (type === "independent" && this.isIndependent(currency))) {
        const currencyObject = {id: currency.id, name: currency.name, balances: balancesArray};
        currencies.push(currencyObject);
      }
    });

    return currencies;
  },

  isIndependent(currency) {
    return currency.type === "airline" && !currency.allianceId;
  },

  render() {
    const account   = this.props.account;
    const owner     = account.owner;
    const companion = account.companion;

    const alliances             = this.getCurrenciesByAlliance();
    const cashCurrencies        = this.getCurrenciesByType("bank");
    const hotelCurrencies       = this.getCurrenciesByType("hotel");
    const independentCurrencies = this.getCurrenciesByType("independent");

    const currencyClass = companion ? "col-xs-4 header" : "col-xs-7 header";

    return (
      <div className="col-xs-12 col-md-6">
        <Row className="header-row">
          <div className="col-xs-2 header"></div>
          <div className={currencyClass}>Currency</div>
          <div className="col-xs-3 header">{owner.firstName}</div>

          {(() => {
            if (companion) {
              return (
                <div className="col-xs-3 header">{companion.firstName}</div>
              );
            }
          })()}

        </Row>

        { alliances.map(alliance => (
          <BalancesTableRow
            key={alliance.id}
            title={alliance.name}
            currencies={alliance.currencies}
            account={this.props.account}
          />
        ))}

        <Row>
          <div className="col-xs-12">
            <BalancesTableRow
              title="Independent"
              currencies={independentCurrencies}
              account={this.props.account}
            />
          </div>
        </Row>

        <Row>
          <div className="col-xs-12">
            <BalancesTableRow
              title="Cash"
              currencies={cashCurrencies}
              account={this.props.account}
            />
          </div>
        </Row>

        <Row>
          <div className="col-xs-12">
            <BalancesTableRow
              title="Hotel"
              currencies={hotelCurrencies}
              account={this.props.account}
            />
          </div>
        </Row>
      </div>
    );
  },
});

export default BalancesTable;
