function TravelPlanTypeRadios(props) {
  return (
    <div className="TravelPlanTypeRadios form-inline">
      {
        props.types.map(function (type, i) {
          return (
            <TravelPlanTypeRadio
              key={i}
              checked={type === props.currentType}
              onClick={props.onChange}
              type={type}
            />
            )
        })
      }
    </div>
  );
};

TravelPlanTypeRadios.propTypes = {
  currentType: React.PropTypes.string.isRequired,
  onChange:    React.PropTypes.func.isRequired,
  types:       React.PropTypes.array.isRequired,
};
