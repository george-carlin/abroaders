import React from "react";

import Button from "../../core/Button";

const SoloFormStep0 = React.createClass({
  propTypes: {
    onSubmit: React.PropTypes.func.isRequired,
  },

  render() {
    return (
      <div>
        <p>
          Abroaders will help you maximize the points you earn with your
          regular monthly spending.
        </p>

        <Button
          onClick={this.props.onSubmit}
          primary
        >
          Sign up for solo earning
        </Button>
      </div>
    );
  },
});

module.exports = SoloFormStep0;
