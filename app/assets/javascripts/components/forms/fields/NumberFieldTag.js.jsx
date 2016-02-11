var NumberFieldTag = React.createClass({
  propTypes: {
    field: React.PropTypes.string.isRequired,
    model: React.PropTypes.string.isRequired,
    value: React.PropTypes.number,
  },


  render() {
    var name = `${this.props.model}[${this.props.field}]`;
    var id   = `${this.props.model}_${this.props.field}`;
    return (
      <input
        className={`form-control`}
        id={id}
        name={name}
        type="number"
        defaultValue={this.props.value}
      />
    );
  }
});
