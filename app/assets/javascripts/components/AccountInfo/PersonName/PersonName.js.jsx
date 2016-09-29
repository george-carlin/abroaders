const React = require("react");

const RadioButton = require("../../core/RadioButton");
const PersonStatus = require("../PersonStatus");

const PersonName = React.createClass({
  propTypes: {
    person: React.PropTypes.object.isRequired,
    withRadio: React.PropTypes.bool.isRequired,
    selected: React.PropTypes.bool,
    onChange: React.PropTypes.func,
  },

  render() {
    const person = this.props.person;

    if (this.props.withRadio) {
      return (
        <label className="radio-inline">
          <RadioButton
            onChange={this.props.onChange}
            attribute="spending_info"
            modelName="account"
            value={person.main ? "owner" : "companion"}
            checked={this.props.selected}
          />

          {person.firstName}

          <PersonStatus
            person={person}
          />
        </label>
      );
    } else {
      return (
        <h1>
          {person.firstName}

          <PersonStatus
            person={person}
          />
        </h1>
      );
    }
  },
});

module.exports = PersonName;
