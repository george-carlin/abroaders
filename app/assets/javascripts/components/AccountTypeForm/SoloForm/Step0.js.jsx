import React from "react";

import Button from "../../core/Button";

const Step0 = (_props) => {
  const props = Object.assign({}, _props);

  return (
      <div>
        <p>
          Abroaders will help you maximize the points you earn with your
          regular monthly spending.
        </p>

        <Button
          onClick={props.onSubmit}
          primary
        >
          Sign up for solo earning
        </Button>
      </div>
  );
};

Step0.propTypes = Object.assign(
  {
    onSubmit: React.PropTypes.func.isRequired,
  }
);

export default Step0;
