const React = require("react");

const RadioButtons  = require("./BusinessRadioButtons");
const SpendingInput = require("./BusinessSpending");

const BusinessInfo = React.createClass({
  getInitialState() {
    return { hasBusiness: "no_business" };
  },

  onChange(e) {
    this.setState({hasBusiness: e.target.value});
  },

  showSpendingInput() {
    return this.state.hasBusiness !== "no_business";
  },

  render() {
    let title;
    if (this.props.useName) {
      title = <h3>Does <b>{this.props.person.firstName}</b> have a business?</h3>;
    } else {
      title = <h3>Do you have a business?</h3>;
    }

    return (
      <div className={this.props.className}>
        {title}

        <RadioButtons
          onChange={this.onChange}
          value={this.state.hasBusiness}
          personType={this.props.person.type}
        />

        {(() => {
          if (this.showSpendingInput())  {
            return <SpendingInput />;
          }
        })()}
      </div>
    );
  },

});

module.exports = BusinessInfo;
