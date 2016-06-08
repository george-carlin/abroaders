const React = require("react");

const FormGroup = React.createClass({
  render() {
    return (
      <div
        {...this.props}
        className={`form-group ${this.props.className}`}
      >
        {this.props.children}
      </div>
    );
  },
});

module.exports = FormGroup;
