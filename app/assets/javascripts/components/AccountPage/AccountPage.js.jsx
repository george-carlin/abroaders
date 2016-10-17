import React from "react";

import Row from "../core/Row";
import BalancesTable from "./BalancesTable";
import AccountTopInfo from "./AccountTopInfo";

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
              <BalancesTable
                account={this.props.account}
                alliances={this.props.alliances}
              />
            </Row>
          </div>
        </div>
      </div>
    );
  },
});

module.exports = AccountPage;
