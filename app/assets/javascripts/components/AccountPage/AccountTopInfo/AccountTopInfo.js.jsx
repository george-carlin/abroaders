import React from "react";

import Row                from "../../core/Row";
import SpendingInfo       from "./SpendingInfo";
import AccountPeopleNames from "./AccountPeopleNames";

const AccountTopInfo = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired,
    person: React.PropTypes.object.isRequired,
    onChooseOwner: React.PropTypes.func.isRequired,
    onChooseCompanion: React.PropTypes.func.isRequired,
  },

  render() {
    const account = this.props.account;
    const person  = this.props.person;

    return (
      <div className="hpanel account-top-info">
        <div className="panel-body">
          <Row>
            <div className="col-xs-12 col-md-6" >

              <AccountPeopleNames
                account={account}
                selectedPerson={person}
                onChooseOwner={this.props.onChooseOwner}
                onChooseCompanion={this.props.onChooseCompanion}
              />

              <p>{account.email}</p>

              {(() => {
                if (account.phoneNumber) {
                  return (
                    <p>{account.phoneNumber}</p>
                  );
                }
              })()}

              <p>Account created: {new Date(account.createdAt).toLocaleDateString()}</p>
            </div>

            <div className="col-xs-12 col-md-6">

              {(() => {
                if (person.spendingInfo) {
                  return (
                    <SpendingInfo
                      account={account}
                      person={person}
                      spendingInfo={person.spendingInfo}
                    />
                  );
                } else {
                  return "User has not added their spending info";
                }
              })()}

            </div>
          </Row>
        </div>
      </div>
    );
  },
});

export default AccountTopInfo;
