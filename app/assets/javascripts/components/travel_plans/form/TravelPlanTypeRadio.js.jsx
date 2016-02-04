var TravelPlanTypeRadio = React.createClass({

  propTypes: {
    checked: React.PropTypes.bool.isRequired,
    onClick: React.PropTypes.func.isRequired,
    type:    React.PropTypes.string.isRequired,
  },


  render() {
    var type  = this.props.type,
        label = type === "multi" ? "Multi-City" : type.capitalize(),
        id    = `travel_plan_type_${type}`;

    return (
      <label htmlFor={id}>
        {label}
        &nbsp;
        <input
          id={id}
          defaultChecked={this.props.checked}
          name="travel_plan_type"
          onClick={this.props.onClick}
          type="radio"
          value={type}
        />
      </label>
    );
  }

});
