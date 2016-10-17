import React from "react";

import Row from "../core/Row";
import BalancesTable from "./BalancesTable";
import AccountTopInfo from "./AccountTopInfo";
import HomeAirportsList from "./HomeAirportsList";
import TravelPlansList from "./TravelPlansList";

const AccountPage = React.createClass({
  propTypes: {
    alliances: React.PropTypes.array.isRequired,
    account: React.PropTypes.object.isRequired,
  },

  render() {
    const account = this.props.account;

    return (
      <div>
        <AccountTopInfo
          account={this.props.account}
        />

       {/*
         hack to create some margin at the top of the page so the fixed position
         'AccountInfo' hpanel doesn't overlap the start of the content
       */}
        <div style={{height: "180px"}}></div>

        <div className="hpanel">
          <div className="panel-body">
            <Row>
              <BalancesTable
                account={account}
                alliances={this.props.alliances}
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
          </div>
        </div>
      </div>
    );
  },
});

module.exports = AccountPage;
