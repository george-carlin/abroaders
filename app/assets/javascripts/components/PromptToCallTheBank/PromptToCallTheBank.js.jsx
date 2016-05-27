const React = require("react");

const PromptToCallTheBank = React.createClass({
  propTypes: {
    card: React.PropTypes.object.isRequired,
    reconsideration: React.PropTypes.bool,
  },

  render() {
    const bank = this.props.card.bank;
    var   phoneNumber;
    if (this.props.card.bp === "personal") {
      phoneNumber = bank.personalPhone;
    } else {
      phoneNumber = bank.businessPhone;
    }

    var secondParagraph;
    if (this.props.reconsideration) {
      secondParagraph = (
        <p>
          More than 30% of applications that are initially denied are
          overturned with a 5-10 minute phone call.
        </p>
      );
    } else {
      secondParagraph = (
        <p>
          You’re more than twice as likely to get approved if you
          call {bank.name} than if you wait for them to send your decision in
          the mail
        </p>
      );
    }

    return (
      <div>
        <p>
          We strongly recommend that you
          call {bank.name} at {phoneNumber} as soon as possible to ask for a
          real person to review your application by phone.
        </p>

        {secondParagraph}
      </div>
    );
  },
});

module.exports = PromptToCallTheBank;
