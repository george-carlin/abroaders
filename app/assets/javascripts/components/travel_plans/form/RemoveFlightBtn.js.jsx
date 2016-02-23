function RemoveFlightBtn(props) {
  return (
    <button
      className="remove-flight-btn btn btn-default"
      data-flight-index={props.index}
      onClick={props.onClick}
      style={ props.hidden ? { display: "none" } : {} }
    >
      -
    </button>
  );
};

RemoveFlightBtn.propTypes = {
  flightIndex: React.PropTypes.number.isRequired,
  hidden:   React.PropTypes.bool.isRequired,
  onClick:  React.PropTypes.func.isRequired,
};
