const React = require("react");

const HelpBlock = React.createClass({
  render() {
    return (
      <p className={`help-block ${this.props.className}`}>
        {this.props.children}
      </p>
    );
  },
});

module.exports = HelpBlock;
