const React = require("react");

const FormGroup   = require("../core/FormGroup");
const NumberField = require("../core/NumberField");

const CreditScore = ({useName, person, className, modelName}) => {
  let title;
  if (useName) {
    title = <h3>What is <b>{person.firstName}'s</b> credit score?</h3>;
  } else {
    title = <h3>What is your credit score?</h3>;
  }

  return (
    <div className={className}>
      {title}

      <FormGroup>
        <NumberField
          attribute={`${person.type}_credit_score`}
          max="850"
          min="350"
          modelName={modelName}
        />
      </FormGroup>
    </div>
  );
};

CreditScore.propTypes = {
  useName:   React.PropTypes.bool,
  person:    React.PropTypes.object.isRequired,
  className: React.PropTypes.string.isRequired,
  modelName: React.PropTypes.string.isRequired,
};

module.exports = CreditScore;
