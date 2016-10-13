import React, { PropTypes } from "react";

import Button from "../core/Button";
import Form   from "../core/Form";

import Fields   from "./Fields";
import HelpText from "./HelpText";
import Layout   from "./Layout";

const EligibilitySurvey = ({ account, action }) => {
  return (
    <Layout>
      <h1>Are You Eligible to Get Credit Cards?</h1>

      <HelpText hasCompanion={!!account.companion} />

      <Form action={action} >
        <Fields
          account={account}
        />

        <Button primary >
          Submit
        </Button>
      </Form>
    </Layout>
  );
};

module.exports = EligibilitySurvey;
