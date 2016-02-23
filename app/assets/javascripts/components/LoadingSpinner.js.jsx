function LoadingSpinner(props) {
  return (
    <div
      className="LoadingSpinner"
      style={props.hidden ? { display: "none" } : {}}
    >
      Loading...
    </div>
  );
}

LoadingSpinner.propTypes    = { hidden: React.PropTypes.bool };
LoadingSpinner.defaultProps = { hidden: false };
