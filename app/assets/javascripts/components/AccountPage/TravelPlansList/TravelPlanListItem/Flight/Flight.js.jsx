import React from "react";

import Row from "../../../../core/Row";

const Flight = (_props) => {
  const props = Object.assign({}, _props);
  const from  = props.flight.from;
  const to    = props.flight.to;

  return (
    <p>
      <i className="fa fa-plane"></i>
      <span> {from} - {to}</span>
    </p>
  );
};

Flight.propTypes = Object.assign(
  {
    flight: React.PropTypes.object.isRequired,
  }
);

export default Flight;
