import React from "react";

import Row from "../../../core/Row";
import CheckBoxWithLabel from "../FilterPanel/CheckBoxWithLabel";

const PersonalBusinessFilter = (_props) => {
  const props  = Object.assign({}, _props);

  return (
    <Row className="personal-business-filter">
      <div className="col-xs-12 col-md-6">
        <CheckBoxWithLabel
          id={"filter-personal"}
          title="Personal"
          onClick={props.onFilterPersonal}
        />

        <CheckBoxWithLabel
          id={"filter-business"}
          title="Business"
          onClick={props.onFilterBusiness}
        />
      </div>
    </Row>
  );
};

PersonalBusinessFilter.propTypes = Object.assign(
  {
    onFilterPersonal: React.PropTypes.func.isRequired,
    onFilterBusiness: React.PropTypes.func.isRequired,
  }
);

export default PersonalBusinessFilter;
