function AuthTokenField(props) {
  return (
    <input
      name="authenticity_token"
      type="hidden"
      value={props.value}
    />
  );
};

AuthTokenField.propTypes = {
  value: React.PropTypes.string
};
