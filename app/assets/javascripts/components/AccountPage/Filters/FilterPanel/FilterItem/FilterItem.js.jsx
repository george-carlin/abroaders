import React from "react";

import CheckBoxWithLabel from "../CheckBoxWithLabel";

const FilterItem = (_props) => {
  const props  = Object.assign({}, _props);
  const item   = props.item;
  const target = props.target;

  return (
    <p>
      <CheckBoxWithLabel
        id={"filter-by-" + target + "-" + item.id}
        title={item.name}
        item={item}
        onClick={props.onClick}
      />
    </p>
  );
};

FilterItem.propTypes = Object.assign(
  {
    item: React.PropTypes.object.isRequired,
    target: React.PropTypes.string.isRequired,
    onClick: React.PropTypes.func.isRequired,
  }
);

export default FilterItem;
