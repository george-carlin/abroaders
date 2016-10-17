const React = require("react");

const PersonStatus = React.createClass({
  propTypes: {
    person: React.PropTypes.object.isRequired,
  },

  render() {
    const person = this.props.person;
    return (
      <span>
        {(() => {
          if (person.ready) {
            return "(R)";
          } else if (person.eligible) {
            return "(E)";
          }
        })()}
      </span>
    );
  },
});

module.exports = PersonStatus;
