import React from "react";

import Row from "../core/Row";

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

export default EligibilitySurveyLayout;
