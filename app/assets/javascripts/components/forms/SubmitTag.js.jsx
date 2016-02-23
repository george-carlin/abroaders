function SubmitTag(props) {
  return (
    <input
      className="SubmitTag btn btn-primary"
      defaultValue={props.value}
      disabled={props.disabled}
      type="submit"
    />
  );
};

SubmitTag.defaultProps = {
  disabled: false,
  value:    "Save changes",
};

SubmitTag.propTypes = {
  disabled: React.PropTypes.bool,
  value:    React.PropTypes.string,
};
