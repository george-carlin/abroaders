const React = require("react");

const InputGroup = React.createClass({
  propTypes: {
    addonAfter:  React.PropTypes.string,
    addonBefore: React.PropTypes.string,
  },


  addon(text) {
    if (text && text.length) {
      return (
        <div className="input-group-addon">
          {text}
        </div>
      );
    }
  },


  render() {
    let addonAfter, addonBefore;

    return (
      <div className="input-group">
        {this.addon(this.props.addonBefore)}

        {this.props.children}

        {this.addon(this.props.addonAfter)}
      </div>
    );
  },
});

module.exports = InputGroup;
