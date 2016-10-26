import React, { PropTypes } from "react";

import Row  from "../core/Row";
import Cols from "../core/Cols";

import SoloForm    from "./SoloForm";
import CouplesForm from "./CouplesForm";

const AccountTypeForm = React.createClass({
  propTypes: {
    action:          PropTypes.string.isRequired,
    destinationName: PropTypes.string,
    ownerName:       PropTypes.string.isRequired,
  },

  getTrip() {
    if (this.props.destinationName && this.props.destinationName.length) {
      return `trip to ${this.props.destinationName}`;
    }
    return "next trip";
  },

  render() {
    const modelName = "account";
    return (
      <Row>
        <Cols xs="12" md="8" mdOffset="2" className="account_type_select_header" >
          <h1>How do you want to earn points?</h1>

          <p>
            Abroaders will help you earn the right points for
            your {this.getTrip()}
          </p>
        </Cols>

        <SoloForm
          action={this.props.action}
          modelName={modelName}
        />

        <CouplesForm
          action={this.props.action}
          modelName={modelName}
          ownerName={this.props.ownerName}
        />
      </Row>
    );
  },
});

module.exports = AccountTypeForm;
