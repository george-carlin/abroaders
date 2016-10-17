import React from "react";

import Row from "../core/Row";
import BalancesTable from "./BalancesTable";
import AccountTopInfo from "./AccountTopInfo";
import HomeAirportsList from "./HomeAirportsList";

const AccountPage = React.createClass({
  propTypes: {
    alliances: React.PropTypes.array.isRequired,
    account: React.PropTypes.object.isRequired,
  },

  render() {
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
              <div className="col-xs-12 col-md-6">
                <BalancesTable
                  account={this.props.account}
                  alliances={this.props.alliances}
                />
              </div>

              <div className="col-xs-12 col-md-6">
                <Row>
                  <div className="col-xs-12 col-md-6">
                    <HomeAirportsList
                      homeAirports={this.props.account.homeAirports}
                    />
                  </div>

                  {/* TODO: Add regions of interests */}
                  <div className="col-xs-12 col-md-6">
                  </div>
                </Row>

                <Row>
                  <div className="col-xs-12">
                  </div>
                </Row>
              </div>
            </Row>
          </div>
        </div>
      </div>
    );
  },
});

module.exports = AccountPage;
