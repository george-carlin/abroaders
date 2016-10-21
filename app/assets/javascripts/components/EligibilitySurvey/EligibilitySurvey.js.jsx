import React, { PropTypes } from "react";

import Button from "../core/Button";
import FAIcon from "../core/FAIcon";
import Form   from "../core/Form";

import Fields   from "./Fields";
import HelpText from "./HelpText";
import Layout   from "./Layout";

const EligibilitySurvey = ({ account, action }) => {
  return (
    <Layout>
      <HelpText hasCompanion={!!account.companion} />

      <Form action={action} >
        <Fields
          account={account}
        />

        <Button primary large >
          <FAIcon check />&nbsp;
          Save and continue
        </Button>
      </Form>
    </Layout>
  );
};

module.exports = EligibilitySurvey;
