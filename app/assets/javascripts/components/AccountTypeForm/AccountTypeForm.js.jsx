import React from "react";

import Row from "../core/Row";

const SoloForm    = require("./SoloForm");
const CouplesForm = require("./CouplesForm");

const AccountTypeForm = React.createClass({
  propTypes: {
    destinationName: React.PropTypes.string,
    ownerName:       React.PropTypes.string.isRequired,
    soloPath:        React.PropTypes.string.isRequired,
    couplesPath:     React.PropTypes.string.isRequired,
  },


  getInitialState() {
    // currentAction is one of "initial", "choosingSolo", "choosingCouples"
    return { currentAction: "initial" };
  },


  onChooseCouples() {
    this.setState({currentAction: "choosingCouples"});
  },


  onChooseSolo() {
    this.setState({currentAction: "choosingSolo"});
  },


  getTrip() {
    if (this.props.destinationName && this.props.destinationName.length) {
      return `trip to ${this.props.destinationName}`;
    }
    return "next trip";
  },


  render() {
    return (
      <Row>
        <div className="account_type_select_header col-xs-12 col-md-8 col-md-offset-2" >
          <h1>How do you want to earn points?</h1>

          <p>
            Abroaders will help you earn the right points for
            your {this.getTrip()}
          </p>
        </div>


        {(() => {
          if (!(this.state.currentAction === "choosingCouples")) {
            return (
              <SoloForm
                active={!(this.state.currentAction === "initial")}
                onChoose={this.onChooseSolo}
                ownerName={this.props.ownerName}
                path={this.props.soloPath}
              />
            );
          }
        })()}

        {(() => {
          if (!(this.state.currentAction === "choosingSolo")) {
            return (
              <CouplesForm
                active={!(this.state.currentAction === "initial")}
                ownerName={this.props.ownerName}
                onChoose={this.onChooseCouples}
                path={this.props.couplesPath}
              />
            );
          }
        })()}

      </Row>
    );
  },
});

module.exports = AccountTypeForm;
