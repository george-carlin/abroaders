import React from "react";

import Row from "../../../../core/Row";
import CheckBoxWithLabel from "../FilterPanel/CheckBoxWithLabel";

const PersonalBusinessFilter = (_props) => {
  const props  = Object.assign({}, _props);

  return (
    <Row className="personal-business-filter">
      <div className="col-xs-12 col-md-6">
        <CheckBoxWithLabel
          id={"filter-personal"}
          className="personal-business-cb"
          title="Personal"
          value="personal"
          onChange={props.onChangeOne}
          checked={props.bpChecked.indexOf("personal") > -1}
          target="bp"
        />

        <CheckBoxWithLabel
          id={"filter-business"}
          className="personal-business-cb"
          title="Business"
          value="business"
          onChange={props.onChangeOne}
          checked={props.bpChecked.indexOf("business") > -1}
          target="bp"
        />
      </div>
    </Row>
  );
};

PersonalBusinessFilter.propTypes = Object.assign(
  {
    onChangeOne: React.PropTypes.func.isRequired,
    bpChecked: React.PropTypes.arrayOf(React.PropTypes.string).isRequired,
  }
);

export default PersonalBusinessFilter;
