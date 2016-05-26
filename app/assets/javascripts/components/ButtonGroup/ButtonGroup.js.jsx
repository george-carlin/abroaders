const React = require("react");

const ButtonGroup = React.createClass({
  render() {
    return (
      <div className="btn-group">
        {this.props.children}
      </div>
    );
  },
});

module.exports = ButtonGroup;
