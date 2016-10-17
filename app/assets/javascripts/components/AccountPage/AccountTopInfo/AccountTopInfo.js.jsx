import React from "react";

import Row                from "../../core/Row";
import SpendingInfo       from "./SpendingInfo";
import AccountPeopleNames from "./AccountPeopleNames";

const AccountTopInfo = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired,
  },

  getInitialState() {
    return { currentAction: "ownerInfo" };
  },

  onChooseOwner() {
    this.setState({currentAction: "ownerInfo"});
  },

  onChooseCompanion() {
    this.setState({currentAction: "companionInfo"});
  },

  render() {
    let person;
    const account   = this.props.account;
    const owner     = account.owner;
    const companion = account.companion;

    if (this.state.currentAction === "ownerInfo") {
      person = owner;
    } else if (this.state.currentAction === "companionInfo") {
      person = companion;
    }

    return (
      <div className="hpanel account-top-info">
        <div className="panel-body">
          <Row>
            <div className="col-xs-12 col-md-6" >

              <AccountPeopleNames
                account={account}
                selectedPerson={person}
                onChooseOwner={this.onChooseOwner}
                onChooseCompanion={this.onChooseCompanion}
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
