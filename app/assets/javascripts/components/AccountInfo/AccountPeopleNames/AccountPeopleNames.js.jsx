const React = require("react");

const RadioButton = require("../../core/RadioButton");
const PersonName = require("../PersonName");

const AccountPeopleNames = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired,
    selectedPerson: React.PropTypes.object.isRequired,
    onChooseOwner: React.PropTypes.func.isRequired,
    onChooseCompanion: React.PropTypes.func.isRequired,
  },

  render() {
    const account = this.props.account;
    const owner     = account.owner;
    const companion = account.companion;

    if (companion) {
      return (
        <p className="people-names">
          <PersonName
            person={owner}
            withRadio
            selected={owner === this.props.selectedPerson}
            onChange={this.props.onChooseOwner}
          />
          <PersonName
            person={companion}
            withRadio
            selected={companion === this.props.selectedPerson}
            onChange={this.props.onChooseCompanion}
          />
        </p>
      );
    } else {
      return (
        <PersonName
          person={owner}
          withRadio={false}
        />
      );
    }
  },
});

module.exports = AccountPeopleNames;
