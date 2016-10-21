import React from "react";

import CheckBoxWithLabel from "./CheckBoxWithLabel";
import FilterItem        from        "./FilterItem";

const FilterPanel = (_props) => {
  const props  = Object.assign({}, _props);
  const title  = props.title;
  const target = props.target;

  return (
    <div className="col-xs-12 col-md-6 filters-large-column">
      <div className="panel panel-primary">
        <div className="panel-heading">
          <CheckBoxWithLabel
            id={"filter-all-for-" + title}
            title={title}
            item={props.item}
            onClick={props.onFilterAll}
          />
        </div>
        <div className="panel-body">
          { props.items.map(item => (
            <FilterItem
              key={item.id}
              item={item}
              target={target}
              onClick={props.onFilter}
            />
          ))}
        </div>
      </div>
    </div>
  );
};

FilterPanel.propTypes = Object.assign(
  {
    title: React.PropTypes.string.isRequired,
    item: React.PropTypes.object,
    items: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    target: React.PropTypes.string.isRequired,
    onFilter: React.PropTypes.func.isRequired,
    onFilterAll: React.PropTypes.func.isRequired,
  }
);

export default FilterPanel;
