function AddFlightBtn(props) {
  return (
    <button
      className="AddFlightBtn btn btn-primary"
      disabled={props.disabled}
      id="add-flight-btn"
      onClick={props.onClick}
      style={props.hidden ? { display: "none" } : {}}
    >
      + Add Flight
    </button>
  )
};

AddFlightBtn.propTypes = {
  disabled: React.PropTypes.bool,
  hidden:   React.PropTypes.bool,
  onClick:  React.PropTypes.func.isRequired,
};
