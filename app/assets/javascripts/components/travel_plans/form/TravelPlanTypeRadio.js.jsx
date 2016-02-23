function TravelPlanTypeRadio(props) {
  var id = `travel_plan_type_${props.type}`;

  return (
    <div className="TravelPlanTypeRadio form-group">
      <label htmlFor={id}>
        {props.type === "multi" ? "Multi-City" : props.type.capitalize()}
        &nbsp;
        <input
          defaultChecked={props.checked}
          id={id}
          name="travel_plan[type]"
          onClick={props.onClick}
          type="radio"
          value={props.type}
        />
      </label>
    </div>
  );
};

TravelPlanTypeRadio.propTypes = {
  checked: React.PropTypes.bool.isRequired,
  onClick: React.PropTypes.func.isRequired,
  type:    React.PropTypes.string.isRequired,
};
