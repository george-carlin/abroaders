import React from "react";

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

export default PersonStatus;
