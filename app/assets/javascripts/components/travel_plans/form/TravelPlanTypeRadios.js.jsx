var TravelPlanTypeRadios = React.createClass({

  propTypes: {
    currentType: React.PropTypes.string.isRequired,
    onChange:    React.PropTypes.func.isRequired,
    types:       React.PropTypes.array.isRequired,
  },


  render() {
    var that = this;

    return (
      <div className="TravelPlanTypeRadios form-inline">
        {
          this.props.types.map(function (type, i) {
            return (
              <TravelPlanTypeRadio
                key={i}
                checked={type === that.props.currentType}
                onClick={that.props.onChange}
                type={type}
              />
            )
          })
        }
      </div>
    );
  }
});
