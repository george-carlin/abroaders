import React from "react";

const CheckBoxWithLabel = React.createClass({
  propTypes: {
    id: React.PropTypes.string.isRequired,
    className: React.PropTypes.string,
    title: React.PropTypes.string.isRequired,
    value: React.PropTypes.string.isRequired,
    onChange: React.PropTypes.func.isRequired,
    checked: React.PropTypes.bool.isRequired,
    target: React.PropTypes.string.isRequired,
  },

  onChangeHandler() {
    this.props.onChange(this);
  },

  render() {
    const props = this.props;
    const id    = props.id;

    return (
      <label htmlFor={id}>
        <input
          id={id}
          className={props.className}
          data-value={props.value}
          type="checkbox"
          onChange={this.onChangeHandler}
          checked={props.checked}
        /> {props.title}
      </label>
    );
  },
});

export default CheckBoxWithLabel;
