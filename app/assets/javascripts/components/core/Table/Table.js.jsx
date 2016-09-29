const React      = require("react");
const classNames = require("classnames");

const Table = React.createClass({
  propTypes: {
    className: React.PropTypes.string,
    striped:   React.PropTypes.bool,
  },

  render() {
    // We have to clone props because it's frozen (i.e. immutable):
    const props = _.clone(this.props);

    props.className = classNames([
      props.className,
      {
        table:           true,
        "table-striped": props.striped,
      },
    ]);

    return <table {...props} />;
  },
});

module.exports = Table;
