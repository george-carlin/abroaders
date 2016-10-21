import React from "react";

const CheckBoxWithLabel = (_props) => {
  const props  = Object.assign({}, _props);
  const id     = props.id;
  const title  = props.title;

  if (props.item) {
    return (
      <label htmlFor={id}>
        <input type="checkbox" id={id} onClick={props.onClick(props.item.id)} /> {title}
      </label>
    );
  } else {
    return (
      <label htmlFor={id}>
        <input type="checkbox" id={id} onClick={props.onClick} /> {title}
      </label>
    );
  }
};

CheckBoxWithLabel.propTypes = Object.assign(
  {
    id: React.PropTypes.string.isRequired,
    title: React.PropTypes.string.isRequired,
    item: React.PropTypes.object,
    onClick: React.PropTypes.func.isRequired,
  }
);

export default CheckBoxWithLabel;
