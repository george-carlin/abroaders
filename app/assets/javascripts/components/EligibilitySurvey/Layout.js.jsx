import React from "react";

import Cols from "../core/Cols";
import Row  from "../core/Row";

const EligibilitySurveyLayout = (props) => {
  const colClasses = { xs: "12", md: "8", mdOffset: "2" };
  return (
    <Row className="hpanel">
      <Cols xs="12" md="8" mdOffset="2">
        <div className="panel-body">
          <h1>Are You Eligible to Get Credit Cards?</h1>
          <hr />
          {props.children}
        </div>
      </Cols>
    </Row>
  );
};

export default EligibilitySurveyLayout;
