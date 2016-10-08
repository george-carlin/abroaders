import React from "react";

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

    var secondParagraphs;
    if (this.props.reconsideration) {
      secondParagraphs = (
        <div>
          <p>
            More than 30% of applications that are initially denied are
            overturned with a 5-10 minute phone call.
          </p>

          <p>
            For more details on getting a decision by phone, check
            out <a href="http://www.abroaders.com/reconsideration-override-application-denials/">
              this resource
            </a>.
          </p>
        </div>
      );
    } else {
      secondParagraphs = (
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

        {secondParagraphs}
      </div>
    );
  },
});

module.exports = PromptToCallTheBank;
