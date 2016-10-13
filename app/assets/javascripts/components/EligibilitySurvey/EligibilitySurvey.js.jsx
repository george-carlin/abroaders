import React, { PropTypes } from "react";

const Button = require("../core/Button");
const Form   = require("../core/Form");

const Fields   = require("./EligibilitySurveyFields");
const HelpText = require("./HelpText");
const Layout   = require("./EligibilitySurveyLayout");

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
