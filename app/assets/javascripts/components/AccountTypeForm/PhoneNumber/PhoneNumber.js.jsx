const React = require("react");

const HelpBlock = require("../../core/HelpBlock");
const FormGroup = require("../../core/FormGroup");
const TextField = require("../../core/TextFieldTag");

const PhoneNumber = React.createClass({
  propTypes: {
    modelName: React.PropTypes.string.isRequired,
  },

  render() {
    return (
      <FormGroup>
        <HelpBlock>
          Optionally, please provide a phone number we can contact you on:
        </HelpBlock>

        <TextField
          attribute="phone_number"
          modelName={this.props.modelName}
          placeholder="Phone number"
        />
      </FormGroup>
    );
  },
});

module.exports = PhoneNumber;
