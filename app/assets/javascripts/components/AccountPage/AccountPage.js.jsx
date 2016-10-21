import React from "react";

import Row              from "../core/Row";
import BalancesTable    from "./BalancesTable";
import AccountTopInfo   from "./AccountTopInfo";
import HomeAirportsList from "./HomeAirportsList";
import TravelPlansList  from "./TravelPlansList";
import Filters          from "./Filters";

const AccountPage = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired,
    alliances: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    banks: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    independentCurrencies: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
  },

  filterByCurrency(currencyId) {
  },

  filterByBank(bankId) {

  },

  filterByBanks() {

  },

  filterByAlliance(allianceId) {

  },

  filterByIndependent() {

  },

  filterByPersonal() {

  },

  filterByBusiness() {

  },

  render() {
    const account   = this.props.account;
    const alliances = this.props.alliances;
    const banks     = this.props.banks;

    return (
      <div>
        <AccountTopInfo
          account={this.props.account}
        />

        /*
         hack to create some margin at the top of the page so the fixed position
         'AccountInfo' hpanel doesn't overlap the start of the content
        */
        <div style={{height: "180px"}}></div>

        <div className="hpanel">
          <div className="panel-body">
            <Row>
              <BalancesTable
                account={account}
                alliances={alliances}
              />

              <div className="col-xs-12 col-md-6">
                <HomeAirportsList
                  homeAirports={account.homeAirports}
                />

                {(() => {
                  if (account.travelPlans.length > 0) {
                    return (
                      <TravelPlansList
                        travelPlans={account.travelPlans}
                      />
                    );
                  }
                })()}
              </div>
            </Row>

            <Filters
              alliances={alliances}
              banks={banks}
              independentCurrencies={this.props.independentCurrencies}
              onFilterBank={this.filterByBank}
              onFilterBanks={this.filterByBanks}
              onFilterCurrency={this.filterByCurrency}
              onFilterAlliance={this.filterByAlliance}
              onFilterIndependent={this.filterByIndependent}
              onFilterPersonal={this.filterByPersonal}
              onFilterBusiness={this.filterByBusiness}
            />
          </div>
        </div>
      </div>
    );
  },
});

module.exports = AccountPage;
