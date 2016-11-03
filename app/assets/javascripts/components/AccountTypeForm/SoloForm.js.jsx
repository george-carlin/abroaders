import React, { PropTypes } from "react";

import Button      from "../core/Button";
import FAIcon      from "../core/FAIcon";
import Form        from "../core/Form";
import HiddenField from "../core/HiddenField";

const SoloForm = (props) => {
  return (
    <Form
      action={props.action}
      className="SoloForm account_type_select hpanel col-xs-12 col-md-4 col-md-offset-2"
      method="post"
    >
      <div className="panel-body">
        <HiddenField
          attribute="type"
          modelName={props.modelName}
          value="solo"
        />

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
      </div>
    </Form>
  );
};

SoloForm.propTypes = {
  action:    PropTypes.string.isRequired,
  modelName: PropTypes.string.isRequired,
};

module.exports = SoloForm;
