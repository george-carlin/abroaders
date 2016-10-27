import React from "react";

import CheckBoxWithLabel from "./CheckBoxWithLabel";

const FilterItem = (_props) => {
  const props  = Object.assign({}, _props);
  const item   = props.item;
  const target = props.target;

  return (
    <p>
      <CheckBoxWithLabel
        id={"filter-by-" + target + "-" + item.id}
        className={props.className}
        title={item.name}
        value={item.id.toString()}
        onChange={props.onChangeOne}
        checked={props.idsChecked.indexOf(item.id) > -1}
        target={target}
      />
    </p>
  );
};

FilterItem.propTypes = Object.assign(
  {
    item: React.PropTypes.object.isRequired,
    target: React.PropTypes.string.isRequired,
    onChangeOne: React.PropTypes.func.isRequired,
    className: React.PropTypes.string,
    idsChecked: React.PropTypes.arrayOf(React.PropTypes.number).isRequired,
  }
);

export default FilterItem;
