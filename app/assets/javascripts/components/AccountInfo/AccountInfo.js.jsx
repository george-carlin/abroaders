const React = require("react");

const Row = require("../core/Row");
const RadioButton = require("../core/RadioButton");

const SpendingInfo = require("./SpendingInfo");

const AccountInfo = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired
  },

  getInitialState() {
    return { currentAction: "ownerInfo" };
  },

  getPersonStatus(person) {
    if (person.ready == true) {
      return " (R)"
    }

    if (person.eligible == true) {
      return " (E)"
    }

    return "";
  },

  onChooseOwner() {
    this.setState({currentAction: "ownerInfo"});
  },

  onChooseCompanion() {
    this.setState({currentAction: "companionInfo"});
  },

  render() {
    let person;
    let account = this.props.account;
    const owner     = account.owner;
    const companion = account.companion;

    if (this.state.currentAction === "ownerInfo") {
      person = owner
    }

    if (this.state.currentAction === "companionInfo") {
      person = companion
    }

    return (
      <div className="hpanel">
        <div className="panel-body">
          <Row>
            <div className="col-xs-12 col-md-6" >

              {(() => {
                if (companion) {
                  return (
                    <p className="people-names">
                      <label className="radio-inline">
                        <RadioButton
                          onChange={this.onChooseOwner}
                          attribute="spending_info"
                          modelName="account"
                          value="owner"
                          checked={this.state.currentAction === "ownerInfo"}
                        />
                        {owner.firstName + this.getPersonStatus(owner)}
                      </label>

                      <label className="radio-inline">
                        <RadioButton
                          onChange={this.onChooseCompanion}
                          attribute="spending_info"
                          modelName="account"
                          value="companion"
                          checked={this.state.currentAction === "companionInfo"}
                        />
                        {companion.firstName + this.getPersonStatus(companion)}
                      </label>
                    </p>
                  );
                }
                else {
                  return (
                    <h1>
                      {owner.firstName + this.getPersonStatus(owner)}
                    </h1>
                  );
                }
              })()}

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
                }
                else {
                  return "User has not added their spending info"
                }
              })()}

            </div>
          </Row>
        </div>
      </div>
    );
  }
});

module.exports = AccountInfo;
