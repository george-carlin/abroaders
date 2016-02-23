function NumberFieldTag(props) {
  var name = `${props.model}[${props.field}]`;
  var id   = `${props.model}_${props.field}`;
  return (
    <input
      className="form-control"
      id={id}
      name={name}
      type="number"
      defaultValue={props.value}
    />
  );
};

NumberFieldTag.propTypes = {
  field: React.PropTypes.string.isRequired,
  model: React.PropTypes.string.isRequired,
  value: React.PropTypes.number,
};
