var React = require('react');

var TravelPlanTypeRadio = React.createClass({

  propTypes: {
    checked: React.PropTypes.bool.isRequired,
    onClick: React.PropTypes.func.isRequired,
    type:    React.PropTypes.string.isRequired,
  },

  render() {
    var id = `travel_plan_type_${this.props.type}`;

    return (
      <div className="TravelPlanTypeRadio form-group">
        <label htmlFor={id}>
          {this.props.type === "multi" ? "Multi-City" : this.props.type.capitalize()}
          &nbsp;
          <input
            defaultChecked={this.props.checked}
            id={id}
            name="travel_plan[type]"
            onClick={this.props.onClick}
            type="radio"
            value={this.props.type}
          />
        </label>
      </div>
    );
  },
});


module.exports = TravelPlanTypeRadio;
