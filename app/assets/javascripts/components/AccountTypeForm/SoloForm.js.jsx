import React, { PropTypes } from "react";

import Button from "../core/Button";
import FAIcon from "../core/FAIcon";
import Form   from "../core/Form";

const SoloForm = ({path}) => {
  return (
    <Form
      action={path}
      className="SoloForm account_type_select well col-xs-12 col-md-4 col-md-offset-2 inactive"
      method="post"
    >
      <h2>
        <FAIcon user />
        &nbsp;
        Solo Earning
      </h2>

      <div>
        <p>
          Abroaders will help you maximize the points you earn with your
          regular monthly spending.
        </p>

        <Button primary >
          Sign up for solo earning
        </Button>
      </div>
    </Form>
  );
};

SoloForm.propTypes = {
  path: PropTypes.string.isRequired,
};

module.exports = SoloForm;
