import React from "react";

import Row from "../../../core/Row";

import RecommendationNote from "./RecommendationNote";

const RecommendationNotes = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired,
  },

  render() {
    return (
      <Row>
        <div className="col-xs-12 col-md-6">

        </div>

        <Row>

        </Row>
      </Row>
    );
  },
});

export default RecommendationNotes;
