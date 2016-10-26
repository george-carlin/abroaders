import React from "react";

import Row                   from "../core/Row";
import BalancesTable         from "./BalancesTable";
import AccountTopInfo        from "./AccountTopInfo";
import HomeAirportsList      from "./HomeAirportsList";
import RegionsOfInterestList from "./RegionsOfInterestList";
import TravelPlansList       from "./TravelPlansList";
import RecommendationsForm   from "./RecommendationsForm";

const AccountPage = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired,
    alliances: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    banks: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    independentCurrencies: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    offers: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
  },

  getInitialState() {
    return {currentAction: "ownerInfo"};
  },

  onChooseOwner() {
    this.setState({currentAction: "ownerInfo"});
  },

  onChooseCompanion() {
    this.setState({currentAction: "companionInfo"});
  },

  render() {
    const account   = this.props.account;
    const alliances = this.props.alliances;

    let person;
    if (this.state.currentAction === "ownerInfo") {
      person = account.owner;
    } else if (this.state.currentAction === "companionInfo") {
      person = account.companion;
    }

    return (
      <div>
        <AccountTopInfo
          account={account}
          person={person}
          onChooseOwner={this.onChooseOwner}
          onChooseCompanion={this.onChooseCompanion}
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
                <Row>
                  <HomeAirportsList
                    homeAirports={account.homeAirports}
                  />

                  {(() => {
                    if (account.regionsOfInterest.length > 0) {
                      return (
                        <RegionsOfInterestList
                          regionsOfInterest={account.regionsOfInterest}
                        />
                      );
                    }
                  })()}
                </Row>

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

            <RecommendationsForm
              person={person}
              alliances={alliances}
              banks={this.props.banks}
              independentCurrencies={this.props.independentCurrencies}
              offers={this.props.offers}
            />
          </div>
        </div>
      </div>
    );
  },
});

module.exports = AccountPage;
