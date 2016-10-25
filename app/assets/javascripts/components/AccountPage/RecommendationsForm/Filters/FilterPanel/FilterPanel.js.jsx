import React from "react";

import CheckBoxWithLabel from "./CheckBoxWithLabel";
import FilterItem        from        "./FilterItem";

const FilterPanel = React.createClass({
  propTypes: {
    title: React.PropTypes.string.isRequired,
    item: React.PropTypes.object,
    items: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    target: React.PropTypes.string.isRequired,
    onChangeOne: React.PropTypes.func.isRequired,
    onChangeAll: React.PropTypes.func.isRequired,
    idsChecked: React.PropTypes.arrayOf(React.PropTypes.number).isRequired,
    filterAllChecked: React.PropTypes.bool.isRequired,
  },

  onChangeAllHandler() {
    this.props.onChangeAll(this);
  },

  onChangeOneHandler(checkbox) {
    this.props.onChangeOne(checkbox, this);
  },

  render() {
    const props = this.props;
    const title = props.title;
    const lowerCaseTitle = title.toLowerCase();
    const target = props.target;
    const checkBoxId = "filter-all-for-" + lowerCaseTitle;

    return (
      <div className={"col-xs-12 col-md-6 filters-large-column " + lowerCaseTitle }>
        <div className="panel panel-primary">
          <div className="panel-heading">
            <CheckBoxWithLabel
              id={checkBoxId}
              className="filter-all-cb"
              title={title}
              value={lowerCaseTitle}
              onChange={this.onChangeAllHandler}
              checked={props.filterAllChecked}
              target={target}
            />
          </div>
          <div className="panel-body">
            { props.items.map(item => (
              <FilterItem
                key={item.id}
                className={target + "-cb"}
                item={item}
                target={target}
                onChangeOne={this.onChangeOneHandler}
                idsChecked={props.idsChecked}
              />
            ))}
          </div>
        </div>
      </div>
    );
  },
});

export default FilterPanel;
