const React = require("react");
const _     = require("underscore");

const Radio  = require("../core/Radio");

const BusinessRadioButtons = (props) => {
  const radios = _.map(
    [
      {
        label: "Yes, with an EIN (Employer ID Number)",
        value: "with_ein",
      }, {
        label: "Yes, without an EIN (Employer ID Number)",
        value: "without_ein",
      }, {
        label: "No, I don't own a business",
        value: "no_business",
      },
    ],
    (radio, i) => {
      return (
        <Radio
          attribute={`${props.personType}_business_spending`}
          checked={props.value === radio.value}
          key={i}
          labelText={radio.label}
          modelName="spending_survey"
          onChange={props.onChange}
          value={radio.value}
        />
      );
    }
  );

  return (
    <div>
      {radios}
    </div>
  );
};

module.exports = BusinessRadioButtons;
