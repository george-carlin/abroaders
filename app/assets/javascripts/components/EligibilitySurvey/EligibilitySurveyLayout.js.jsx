import React from "react";

const Row = require("../core/Row");

const EligibilitySurveyLayout = (props) => {
  return (
    <Row>
      <div className="col-xs-12 col-md-8 col-md-offset-2">
        <div className="hpanel">
          <div className="panel-body">
            {props.children}
          </div>
        </div>
      </div>
    </Row>
  );
};

module.exports = EligibilitySurveyLayout;
