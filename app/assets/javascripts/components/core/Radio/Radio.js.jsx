const React = require("react");
const _     = require("underscore");

const RadioButton = require("../RadioButton");

const Radio = React.createClass({
  propTypes: {
    labelText: React.PropTypes.string,
  },

  render() {
    const props     = _.clone(this.props)
    const labelText = props.labelText;
    delete props.labelText;

    return (
      <div className="radio">
        <label>
          <RadioButton {...props} />
          {labelText}
        </label>
      </div>
    );
  },
});

module.exports = Radio;
