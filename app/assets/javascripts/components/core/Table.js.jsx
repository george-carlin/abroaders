const React      = require("react");
const classNames = require("classnames");

const Table = (_props) => {
  const props = Object.assign({}, _props);

  props.className = classNames([
    props.className,
    {
      table:           true,
      "table-striped": props.striped,
    },
  ]);

  return <table {...props} />;
};

Table.propTypes = {
  className: React.PropTypes.string,
  striped:   React.PropTypes.bool,
};

module.exports = Table;
