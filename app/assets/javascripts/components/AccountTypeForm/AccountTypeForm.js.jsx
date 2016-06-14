const React = require("react");

const Row = require("../core/Row");

const SoloForm    = require("./SoloForm");
const PartnerForm = require("./PartnerForm");

const AccountTypeForm = React.createClass({
  propTypes: {
    destinationName: React.PropTypes.string,
    mainPersonName:  React.PropTypes.string.isRequired,
    soloPath:        React.PropTypes.string.isRequired,
    partnerPath:     React.PropTypes.string.isRequired,
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


        <SoloForm
          path={this.props.soloPath}
        />

        <PartnerForm
          mainPersonName={this.props.mainPersonName}
          path={this.props.partnerPath}
        />

      </Row>
    );
  },
});

module.exports = AccountTypeForm;
